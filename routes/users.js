// routes/users.js
var express = require('express');
var router = express.Router();
const db = require('../db'); // make sure path is correct

/* GET users listing. */
router.get('/', function(req, res, next) {
  db.query('SELECT * FROM users', (err, results) => {
    if (err) {
      return next(err);
    }
    res.json(results); // send results as JSON
  });
});

module.exports = router;
