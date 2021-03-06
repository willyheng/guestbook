-- :name save-message! :<! :1
-- :doc creates a new message using the name and message keys
INSERT INTO posts
(author, name, message, parent)
VALUES (:author, :name, :message, :parent)
RETURNING *;

-- :name get-message :? :1
-- :doc selects a message
SELECT * FROM posts_with_meta
  INNER JOIN (SELECT id, parent FROM posts) AS p USING (id)
  INNER JOIN reply_count USING (id)
WHERE id = :id

-- :name get-messages :? :*
-- :doc selects all available messages
SELECT * FROM posts_with_meta

-- :name get-messages-by-author :? :*
-- :doc selects all messages from author
SELECT * FROM posts_with_meta
WHERE author = :author

-- :name get-replies :? :*
-- :doc gets replies
SELECT * FROM posts_with_meta
  INNER JOIN (SELECT id, parent FROM posts) AS p USING (id)
  INNER JOIN reply_count USING (id)
WHERE id IN (SELECT id FROM posts
              WHERE parent = :id)

-- :name create-user! :! :n
-- :doc creates a new user with provided login and hashed password
INSERT INTO users
(login, password)
VALUES (:login, :password)

-- :name get-user-for-auth* :? :1
-- :doc selects a user for authentication
SELECT * FROM users
WHERE login = :login

-- :name set-profile-for-user* :<! :1
-- :doc sets a profile map for the specified user
UPDATE users
SET profile = :profile
WHERE login = :login
RETURNING *;

-- :name get-user* :? :1
-- :doc gets a user's publicly available information
SELECT login, created_at, profile from users
WHERE login = :login

-- :name save-file! :! :n
-- :doc saves a file to the database
INSERT INTO media
(name, type, owner, data)
VALUES (:name, :type, :owner, :data)
ON CONFLICT (name) DO UPDATE
SET type = :type,
    data = :data
WHERE media.owner = :owner

-- :name get-file :? :1
-- :doc gets a file from the database
SELECT * FROM media
WHERE name = :name

-- :name set-password-for-user!* :! :n
-- :doc sets a user password
UPDATE users
SET password = :password
WHERE login = :login

-- :name delete-user!* :! :n
DELETE FROM users
WHERE login = :login

-- :name boost-post! :! :n
-- :doc Boosts a post, or moves a boost to the top of the user's timeline
INSERT INTO boosts
(user_id, post_id, poster)
VALUES (:user, :post, nullif(:poster, :user))
ON CONFLICT (user_id, post_id) DO UPDATE
SET timestamp = now()
WHERE boosts.user_id = :user
AND boosts.post_id = :post

-- :name boosters-of-post :? :*
-- :doc Get all boosters of a post
SELECT user_id AS user FROM boosts
WHERE post_id = :post

-- :name get-reboosts :? :*
-- :doc Gets all boosts descended from a given boost
WHERE RECURSIVE reboosts AS
(WITH post_boosts AS
 (SELECT user_id, poster
  FROM boosts
  WHERE post_id = :post)
 SELECT user_id, poster
 FROM post_boosts
 WHERE user_id = :user
 UNION
 SELECT b.user_id, b.poster
 FROM post_boosts b INNER JOIN reboosts r ON r.user_id = b.poster)
SELECT user_id AS user, poster AS source FROM reboosts

-- :name get-boost-chain :? :*
-- :doc Gets all boosts above the original boost
WITH RECURSIVE reboosts AS
(WITH post_boosts AS
 (SELECT user_id, poster
  FROM boosts
  WHERE post_id = :post)
 SELECT user_id, poster
 FROM post_boosts
 WHERE user_id = :user
 UNION
 SELECT b.user_id, b.poster
 FROM post_boosts b INNER JOIN reboosts r ON r.poster = b.user_id)
SELECT user_id AS user, poster AS source FROM reboosts

-- :name get-timeline :? :*
-- :doc gets the latest post or boost for each post
SELECT * FROM
(SELECT DISTINCT ON (p.id) * FROM posts_and_boosts AS p
 ORDER BY p.id, p.posted_at DESC) AS t
 ORDER BY t.posted_at ASC

-- :name get-timeline-for-poster :? :*
-- :doc gets the latest post or boost for each post
SELECT * FROM
(SELECT DISTINCT ON (p.id) * FROM posts_and_boosts AS p
 WHERE p.poster = :poster
 ORDER BY p.id, p.posted_at DESC) AS t
ORDER BY t.posted_at ASC

-- :name get-timeline-post :? :1
-- :doc gets the boosted post for updating timelines
SELECT * FROM posts_and_boosts
WHERE is_boost = :is_boost
AND poster = :user
AND id = :post
ORDER BY posted_at ASC
LIMIT 1

-- :name get-parents :?
-- :doc get the parents of post
SELECT * FROM posts_with_meta
  INNER JOIN (SELECT id, parent FROM posts) AS p USING (id)
  INNER JOIN reply_count USING (id)
WHERE id IN (WITH RECURSIVE parents AS
              (SELECT id, parent FROM posts
                WHERE id = :id
              UNION
              SELECT p.id, p.parent FROM posts p
                INNER JOIN parents pp
                ON p.id = pp.parent)
             SELECT id FROM parents)
