// driver-service/index.js
const express = require("express");
const bodyParser = require("body-parser");
const { Pool } = require("pg");
const { createClient } = require("redis");

const app = express();
app.use(bodyParser.json());

// PostgreSQL pool
const pg = new Pool({ connectionString: process.env.PG_URL });

// Redis client
const redis = createClient({ url: process.env.REDIS_URL });
redis.connect().then(() => console.log("Redis connected"));

// Health check endpoint for Kubernetes probes
app.get("/drivers/health", async (req, res) => {
  try {
    // Check if database is connected
    await pg.query('SELECT 1');
    
    // Check if Redis is connected
    if (!redis.isReady) {
      throw new Error("Redis connection not ready");
    }
    
    res.status(200).json({ status: 'healthy' });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});

// 1. Create driver
app.post("/drivers", async (req, res) => {
  console.log("Creating driver", req.body);
  const { name, vehicle } = req.body;
  const { rows } = await pg.query(
    "INSERT INTO drivers(name, vehicle) VALUES($1, $2) RETURNING *",
    [name, vehicle]
  );
  res.status(201).json(rows[0]);
});

// 2. Set availability
app.post("/drivers/:id/availability", async (req, res) => {
  const driverId = req.params.id;
  const { available } = req.body;

  if (available) {
    // add to Redis set
    await redis.sAdd("available_drivers", driverId);
  } else {
    // remove from Redis set
    await redis.sRem("available_drivers", driverId);
  }

  res.json({ driverId, available });
});

// 3. List available drivers
app.get("/drivers/available", async (req, res) => {
  const ids = await redis.sMembers("available_drivers");
  if (!ids.length) return res.json([]);

  const { rows } = await pg.query(
    `SELECT * FROM drivers WHERE id = ANY($1::int[])`,
    [ids.map((id) => parseInt(id))]
  );
  res.json(rows);
});

app.listen(4002, () => console.log("Driver Service on port 4002"));
