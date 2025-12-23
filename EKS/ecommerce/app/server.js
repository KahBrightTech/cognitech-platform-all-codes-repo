const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  user: process.env.DB_USER || 'ecomuser',
  password: process.env.DB_PASS || 'ecompass',
  database: process.env.DB_NAME || 'ecomdb',
  port: 5432
});

// Get all products
app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'DB error' });
  }
});

// Checkout
app.post('/api/checkout', async (req, res) => {
  const { cart } = req.body;
  // In a real app, you'd process payment, create order, etc.
  res.json({ message: 'Order placed! (Demo)' });
});

app.listen(3000, () => {
  console.log('App server running on port 3000');
});
