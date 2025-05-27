var express = require('express');
var router = express.Router();

router.get('/results', (req, res) => {
  // Session data, results after form, etc.
  res.send('Here are your results!');
});
module.exports = router;
