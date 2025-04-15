CREATE TABLE IF NOT EXISTS rides (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  driver_id INTEGER,
  pickup TEXT NOT NULL,
  dropoff TEXT NOT NULL,
  status TEXT NOT NULL
);
