CREATE OR REPLACE VIEW posts_with_meta AS
SELECT
p.id                    as id,
p.timestamp             as timestamp,
p.message               as message,
p.name                  as name,
p.author                as author,
a.profile->>'avatar'    as avatar,
count(b.user_id)        as boosts
FROM posts AS p
LEFT JOIN users AS a ON a.login = p.author
LEFT JOIN boosts AS b ON p.id = b.post_id
GROUP BY p.id, a.login
--;;
CREATE OR REPLACE VIEW posts_and_boosts AS
SELECT
p.id                    as id,
p.timestamp             as timestamp,
p.message               as message,
p.name                  as name,
p.author                as author,
p.avatar                as avatar,
p.boosts                as boosts,
b.post_id IS NOT NULL   as is_boost,
COALESCE(b.timestamp, p.timestamp)      as posted_at,
COALESCE(b.user_id, p.author)           as poster,
COALESCE(u.profile->>'avatar', p.avatar)   as poster_avatar,
COALESCE(b.poster, p.author)               as source,
COALESCE(s.profile->>'avatar', p.avatar)   as source_avatar
FROM posts_with_meta AS p
LEFT JOIN boosts     AS b ON b.post_id = p.id
LEFT JOIN users      AS u ON b.user_id = u.login
LEFT JOIN users      AS s ON b.poster = s.login
