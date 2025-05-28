const express = require('express');
const router = express.Router();


// LOGIC TREE
// From users main menu, finish contact info, session declaration -> Go to Quizzes Page -> Select a Quiz
// -> Backend Receives Grade from Quiz Selected -> Fetch Questions from Database based on Grade
// -> User Hits Submit on Quiz -> Results filed into database 'results column' for user -> User checks the results page which collects from column (results.js)

// Test: Does session name stay from users.js? Does multiple users cause intersecting sessions? Is there any way to break the quiz selection
/**
 * GET /quiz
 * - Get list of quiz topics
 * - Used to show options for the user to choose from
 * - TODO: Query the topics from DB
 */
// All x-www-urlencoded are string literals
router.post('/', async (req, res) => { // Get Grade, User selects a quiz
  grade = req.body.Grade; // Select a quiz from frontend
  req.session.user.grade = grade; 
  // <-- HERE Frontend redirects to quiz page 
  const [tableQuestions] = await db.query( // Quiz loads with questions 
      'SELECT * FROM Questions WHERE Topics = ?',
      [Grade]
    ); // Show questions to Frontend
});

router.post('/submit', async (req, res) => {
  // SELECT Grade getGrade From the mySQL Database 
  if (req.session.user){ // If there's a user
    console.log("Session: " + req.session.user.name); // test
    const questionAnswers = [req.body.Q1, req.body.Q2, req.body.Q3, req.body.Q4, req.body.Q5, req.body.Q6, red.body.Q7, req.body.Q8, req.body.Q9, req.body.Q10];
    const [rows] = await db.query( // Gives you answers from the grade question list
      'SELECT * FROM Answers WHERE Topics = ?',
      [req.session.user.grade]
    );
    for (let i = 0; i < 10; i++) {
      if (questionAnswers[i] == rows[i].answers_id){
        // Mark Question Correct, save result into User data using Insert
      }
    }
    // Frontend Redirects to Results tab
  }
})

/**
 * POST /quiz
 * - Receive selected topic from user
 * - Return quiz questions for that topic
 * - TODO: Fetch and send quiz questions from DB
 */
router.post('/', (req, res) => {
  const { topicId } = req.body;
  // TODO: Validate topicId, query DB, return quiz questions
  res.json({ questions: [] });
});

module.exports = router;
