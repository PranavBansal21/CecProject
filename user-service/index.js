// user-service/index.js
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

const app = express();
app.use(bodyParser.json());

const pool = new Pool({
  connectionString: process.env.PG_URL,
});

// Health check endpoint for Kubernetes probes
app.get('/health', async (req, res) => {
  try {
    // Check if database is connected
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'healthy' });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});

app.post('/', async (req, res) => {
  const { name, email } = req.body;
  const result = await pool.query(
    'INSERT INTO users(name, email) VALUES($1, $2) RETURNING *',
    [name, email]
  );
  res.json(result.rows[0]);
});

app.get('/:id', async (req, res) => {
  const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
  if (!result.rows.length) return res.status(404).json({ error: 'Not found' });
  res.json(result.rows[0]);
});

app.get('/', async (req, res) => {
  res.json({ message: 'User service is running' });
});

app.listen(4001, () => console.log('User Service running on port 4001'));
