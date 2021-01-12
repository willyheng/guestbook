-- :name save-message! :! :n
-- :doc creates a new message using name and message keys
INSERT INTO posts
(name, message)
VALUES (:name, :message)

-- :name get-messages :? :*
-- :doc selects all available messages
SELECT * FROM posts
