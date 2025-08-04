const express = require('express');
const router = express.Router();

// Centralize all route files
router.use('/users', require('./users'));
router.use('/quiz', require('./quiz'));
router.use('/results', require('./results'));

module.exports = router;
