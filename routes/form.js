var express = require('express');
var router = express.Router();
const session = require('express-session');
const app = require('../app');
// GET = Requesting Data (read only) from browser url
// POST = Submitting data from Request's body. Request has multiple fields.
// ex. http://localhost:3000/form/submit 
//      ^->  /form/submit as req -> strips '/form', results in '/submit' -> formRouter checks router.get('/grade8')


// Main Menu (Contact Info, Select Form) -> Form (Grade 8-12) -> Results -> Main Menu
router.post('/', (req, res) => { // Trigger on main menu clickbutton
  // Session data, results after form, etc.
  req.session.user = {
    name: req.body.Name,
    email: req.body.Email,
    phone: req.body.Phone,
    grade: req.body.grade
  };
  res.redirect('/form/submit'); // redirect to the actual form that we'll fill out.
// Saves data into the database
  // Redirects you to the form where'd you fill out questions 
  // At the end re-fill out information and confirms with database
  // OR
  // Put it into url httpsf.fjodoidfj/form/NameEmailPhoneGrade
});

router.post('/submit', (req, res) => {
  // SELECT Grade getGrade From the mySQL Database 
  if (req.session.user){
    console.log("Question 1: " + req.body.Q1);
    console.log("Question 2: " + req.body.Q2);
    console.log("Question 3: " + req.body.Q3);
    console.log("Question 4: " + req.body.Q4);
    console.log("Question 5: " + req.body.Q5);
    console.log("Question 6: " + req.body.Q6);
    console.log("Question 7: " + req.body.Q7);
    console.log("Question 8: " + req.body.Q8);
    console.log("Question 9: " + req.body.Q9);
    console.log("Question 10: " + req.body.Q10);
    console.log("Session: " + req.session.user.name);
    // SAVE INTO DATABASE USING GRADE**
  
    res.redirect('/form/results'); // Results form will recollect data from consistent session ID number, username, password, email, all submitted at the start of the form.
  // The session data will be saved in req.session.username, etc. Results form will then display results pertaining to the parameter using views folder, images, and other tools.
  }
})
module.exports = router;