var express = require('express');
var router = express.Router();
// GET = Requesting Data (read only) from browser url
// POST = Submitting data from Request's body. Request has multiple fields.
// ex. http://localhost:3000/form/submit 
//      ^->  /form/submit as req -> strips '/form', results in '/submit' -> formRouter checks router.get('/grade8')

// Main Menu (Contact Info, Select Form) -> Form (Grade 8-12) -> Results -> Main Menu
router.post('/', (req, res) => {
  // Session data, results after form, etc.
  res.send('Here are your results!');
});

router.post('/submit', (req, res) => { 
  console.log("Name: " + req.body.Name);
  console.log("Email: " + req.body.Email);
  console.log("Phone: " + req.body.Phone);
  console.log("Grade: " + req.body.Grade);
  console.log(req.body);
  // req.body will have list of hard-coded parameters, hidden/public, such as grade, question number, 
  // and relevant user answer for question number. This data will be saved to the database.

  // req.body.answerOne or answerTwo, etc. will be cross checked through if-statements, as it's a multiple choice 
  // exam. The form then calculates the graded result based on internal logic, and then it saves the results in database.
  
  res.redirect('/form/results'); // Results form will recollect data from consistent session ID number, username, password, email, all submitted at the start of the form.
  // The session data will be saved in req.session.username, etc. Results form will then display results pertaining to the parameter using views folder, images, and other tools.
})
module.exports = router;
