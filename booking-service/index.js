const express = require("express");
const bodyParser = require("body-parser");
const { Pool } = require("pg");
const amqp = require("amqplib");

const app = express();
app.use(bodyParser.json());

const pg = new Pool({ connectionString: process.env.PG_URL });

let channel;
let connection;

// Connect to RabbitMQ
async function connectRabbit() {
  connection = await amqp.connect(process.env.RABBIT_URL);
  channel = await connection.createChannel();
  await channel.assertQueue("ride_events");
  console.log("Connected to RabbitMQ");
}

connectRabbit();

// Health check endpoint for Kubernetes probes
app.get("/rides/health", async (req, res) => {
  try {
    // Check if database is connected
    await pg.query('SELECT 1');
    
    // Check if RabbitMQ is connected
    if (!channel || !connection) {
      throw new Error("RabbitMQ connection not ready");
    }
    
    res.status(200).json({ status: 'healthy' });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});

// 1. Request a Ride
app.post("/rides", async (req, res) => {
  const { userId, pickup, dropoff } = req.body;
  const { rows } = await pg.query(
    "INSERT INTO rides(user_id, pickup, dropoff, status) VALUES($1, $2, $3, $4) RETURNING *",
    [userId, pickup, dropoff, "pending"]
  );
  res.status(201).json(rows[0]);
});

// 2. Assign Driver
app.post("/rides/:id/assign", async (req, res) => {
  const rideId = req.params.id;
  const { driverId } = req.body;

  const { rows } = await pg.query(
    `UPDATE rides SET driver_id=$1, status='ongoing' WHERE id=$2 RETURNING *`,
    [driverId, rideId]
  );

  const ride = rows[0];

  // Publish event to RabbitMQ
  channel.sendToQueue(
    "ride_events",
    Buffer.from(
      JSON.stringify({
        type: "ride_assigned",
        data: ride,
      })
    )
  );

  res.json(ride);
});

// 3. Complete Ride
app.post("/rides/:id/complete", async (req, res) => {
  const rideId = req.params.id;

  const { rows } = await pg.query(
    `UPDATE rides SET status='completed' WHERE id=$1 RETURNING *`,
    [rideId]
  );

  const ride = rows[0];

  // Notify
  channel.sendToQueue(
    "ride_events",
    Buffer.from(
      JSON.stringify({
        type: "ride_completed",
        data: ride,
      })
    )
  );

  res.json(ride);
});

// 4. Get Ride Info
app.get("/rides/:id", async (req, res) => {
  const rideId = req.params.id;
  const { rows } = await pg.query(`SELECT * FROM rides WHERE id=$1`, [rideId]);
  if (rows.length === 0) return res.status(404).json({ error: "Not found" });
  res.json(rows[0]);
});

app.get("/", async (req, res) => {
  res.json({ message: 'Booking Service is running' });
});

app.listen(4003, () => console.log("Booking Service on port 4003"));
