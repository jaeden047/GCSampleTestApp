var express = require('express');
var router = express.Router();
import { getGrade } from './mainmenu.js'; // Use grade to connect to database to connect to results.
// Only works if this is really local, otherwise likely an error.
router.get('/results', (req, res) => {
  res.send('Here are your results!');
});
module.exports = router;
