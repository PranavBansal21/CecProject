CREATE TABLE IF NOT EXISTS drivers (
  id      SERIAL PRIMARY KEY,
  name    TEXT   NOT NULL,
  vehicle TEXT   NOT NULL
);
