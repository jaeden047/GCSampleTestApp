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
  const grade = req.body.Grade; // Select a quiz from frontend
  req.session.user.grade = grade;
  // <-- HERE Frontend redirects to quiz page
  const [tableQuestions] = await db.query( // Quiz loads with questions
      'SELECT * FROM Questions WHERE Topics = ? ORDER BY RAND() LIMIT 10',
      [grade]
    );
for (let question of tableQuestions) {
  const [tableAnswers] = await db.query(
    'SELECT * FROM Answers WHERE question_id = ? ORDER BY RAND() LIMIT 4',
    [question.question_id] // *
  );
}
  //res.json({ questions: tableQuestions }, { answers: tableAnswers }); // Show questions to Frontend, *need to display
});
router.post('/submit', async (req, res) => {
  // SELECT Grade getGrade From the mySQL Database
  if (req.session.user){ // If there's a user
    console.log("Session: " + req.session.user.name); // test
    // USER'S ANSWERS BELOW
    const questionAnswers = [req.body.Q1, req.body.Q2, req.body.Q3, req.body.Q4, req.body.Q5, req.body.Q6, req.body.Q7, req.body.Q8, req.body.Q9, req.body.Q10];
    for (let answer of questionAnswers) {
       const [tableCorrectAnswers] = await db.query(
        'SELECT * FROM Answers WHERE question_id = ? AND is_correct = TRUE', // *
        [answer.question_id] // *
      );
    }
    answerCount = 0;
    for (let i = 0; i < 10; i++) {
      if (tableCorrectAnswers[i].question_id == questionAnswers[i].question_id){
        answerCount++;
        // Mark Question Correct, save result into User data using Insert
        // INSERT INTO RESULTS, TESTATTEMPTS
      }
    }
    // Frontend Redirects to Results tab
  }
})
module.exports = router;