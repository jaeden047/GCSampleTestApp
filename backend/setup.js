const fs = require('fs');
const db = require('./db');

const schema = fs.readFileSync('./setup-schema.sql', 'utf8');

(async () => {
  try {
    await db.query(schema);
    console.log('Schema applied.');
    process.exit(0);
  } catch (err) {
    console.error('Error setting up schema:', err.message);
    process.exit(1);
  }
})();
