// db.js - Set up PostgreSQL connection using `pg` library
require('dotenv').config();
const { Client } = require('pg');

// Create a new PostgreSQL client instance
const client = new Client({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,  // Default PostgreSQL port
  ssl: { rejectUnauthorized: false }  // SSL for Supabase connection
});

// Connect to PostgreSQL database
async function connectDb() {
  if (!client._connected) {
    await client.connect();
  }
  return client;
}

module.exports = connectDb;
