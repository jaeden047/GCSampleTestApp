const express = require('express');
const router = express.Router();

/**
 * GET /users
 * - Fetch user info from DB
 * - Used for authentication/session check
 * - TODO: Replace mock response with real DB lookup
 */
router.get('/', (req, res) => {
  // TODO: Fetch user data based on session or cookie
  // Name, email and phone number(optional) 
  // refer to User Table from db
  res.json({ message: 'User info goes here' });
});




/** This part is maybe how we do backend fetching from db */
// const db = require('../db'); // make sure path is correct

//   //GET users listing. 
//   router.get('/db-test', (req, res) => {
//   db.query('SELECT NOW() AS now', (err, results) => {
//     if (err) return res.status(500).json({ error: err.message });
//     res.json({ time: results[0].now }); // send results as JSON
//   });
// }); 

module.exports = router;
