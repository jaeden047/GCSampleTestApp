var express = require('express');
var router = express.Router();  
export let grade = null;

  router.post('/', (req, res) => { // Trigger on main menu clickbutton
  // Session data, results after form, etc.
    console.log("Name: " + req.body.Name);
    console.log("Email: " + req.body.Email);
    console.log("Phone: " + req.body.Phone);
    console.log("Grade: " + req.body.Grade);
// MUST SAVE DATA***
    grade = parseInt(req.body.Grade); // Save
    res.redirect('/form'); // Head to form, save in db
});

export function getGrade() {
  return grade;
}