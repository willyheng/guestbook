ALTER TABLE posts
 ADD COLUMN parent INTEGER REFERENCES posts(id);
