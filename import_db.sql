DROP TABLE IF EXISTS users;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)

);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  author_id INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,

  FOREIGN KEY (author_id) REFERENCES user(id),
  FOREIGN KEY (parent_id)  REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES user(id),
  FOREIGN KEY (question_id) REFERENCES question(id)
);

INSERT INTO
    users (fname, lname)
VALUES
  ('Albertum', 'Bernard'),
  ('Charlie', 'Chuck');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ("Why?", "Just Because", (SELECT id FROM users WHERE fname = 'Albertum')),
  ("When?", "Now", (SELECT id FROM users WHERE fname = 'Albertum')),
  ("Where?", "App Academy", (SELECT id FROM users WHERE fname = 'Charlie'))
  ;

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Charlie'),
  (SELECT id FROM questions WHERE title = 'Why?'));

INSERT INTO
  replies (question_id, parent_id, author_id, body)
VALUES
  ((SELECT id from questions WHERE title = 'Why?'),
  NULL,
  (SELECT id from users WHERE fname = 'Albertum'),
  "this is the reply body!"),

  ((SELECT id from questions WHERE title = 'Why?'),
  1,
  --(SELECT id from replies WHERE id = 1 ),
  (SELECT id from users WHERE fname = 'Charlie'),
  "this is the reply body!"),

  ((SELECT id from questions WHERE title = 'Why?'),
  2,
  --(SELECT id from replies WHERE id = 2 ),
  (SELECT id from users WHERE fname = 'Albertum'),
  "yooooooooo!");

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (
    (SELECT id from users WHERE fname = 'Albertum'),
    (SELECT id from questions WHERE title = 'Why?')
  ),

  (
    (SELECT id from users WHERE fname = 'Charlie'),
    (SELECT id from questions WHERE title = 'Why?')
  );
