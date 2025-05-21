var express = require('express');
var router = express.Router();
// req receives info about request
// res generates response to browser
// duplicate routes don't work, only first duplicate in order gets complete. 

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' }); 
  // response: check /views/index/ with title variable as 'Express', responds to browser
});

router.get('/', (req, res) => {
  res.send('Hello World!') // response: 'Hello World!' on browser
})

module.exports = router;
