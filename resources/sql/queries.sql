-- :name save-message! :<! :1
-- :doc creates a new message using the name and message keys
INSERT INTO posts
(author, name, message)
VALUES (:author, :name, :message)
RETURNING *;

-- :name get-messages :? :*
-- :doc selects all available messages
SELECT
  p.id                  as id,
  p.timestamp           as timestamp,
  p.message             as message,
  p.name                as name,
  p.author              as author,
  a.profile->>'avatar'  as avatar
FROM posts AS p JOIN users AS a
ON a.login = p.author

-- :name get-messages-by-author :? :*
-- :doc selects all messages from author
SELECT
  p.id                  as id,
  p.timestamp           as timestamp,
  p.message             as message,
  p.name                as name,
  p.author              as author,
  a.profile->>'avatar'  as avatar
FROM posts AS p JOIN users AS a
ON a.login = p.author
WHERE author = :author

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
