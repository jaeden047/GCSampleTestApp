// build database tables, one-off use
const fs = require('fs');
const db = require('./db');

const schema = fs.readFileSync('./setup-schema.sql', 'utf8');

db.query(schema, (err) => {
  if (err) {
    console.error('Error setting up schema:', err.message);
    process.exit(1);
  }
  console.log('Schema applied.');
  process.exit(0);
});