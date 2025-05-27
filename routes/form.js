var express = require('express');
var router = express.Router();
// GET = Requesting Data (read only) from browser url
// POST = Submitting data from Request's body. Request has multiple fields.
// ex. http://localhost:3000/form/submit 
//      ^->  /form/submit as req -> strips '/form', results in '/submit' -> formRouter checks router.get('/grade8')

// Main Menu (Contact Info, Select Form) -> Form (Grade 8-12) -> Results -> Main Menu
router.post('/', (req, res) => {
});

import { getGrade } from './mainmenu.js'; // USE FOR DATABASE SAVING, IS IT LOCAL?

router.post('/g8/submit', (req, res) => { 
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
  // SAVE INTO DATABASE USING GRADE**
  
  res.redirect('/form/results'); // Results form will recollect data from consistent session ID number, username, password, email, all submitted at the start of the form.
  // The session data will be saved in req.session.username, etc. Results form will then display results pertaining to the parameter using views folder, images, and other tools.
})

router.post('/g910/submit', (req, res) => { 
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
  // SAVE INTO DATABASE**
  
  res.redirect('/form/results'); // Results form will recollect data from consistent session ID number, username, password, email, all submitted at the start of the form.
  // The session data will be saved in req.session.username, etc. Results form will then display results pertaining to the parameter using views folder, images, and other tools.
})

router.post('/g1112/submit', (req, res) => { 
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
  // SAVE INTO DATABASE UNDER MAIN MENU LOGIN**

  res.redirect('/form/results'); // Results form will recollect data from consistent session ID number, username, password, email, all submitted at the start of the form.
  // The session data will be saved in req.session.username, etc. Results form will then display results pertaining to the parameter using views folder, images, and other tools.
})
module.exports = router;
