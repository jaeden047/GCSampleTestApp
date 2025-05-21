// routes/users.js
var express = require('express');
var router = express.Router();
const db = require('../db'); // make sure path is correct

/* GET users listing. */
router.get('/db-test', (req, res) => {
  db.query('SELECT NOW() AS now', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ time: results[0].now }); // send results as JSON
  });
});

module.exports = router;
