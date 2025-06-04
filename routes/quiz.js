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
      'SELECT * FROM Questions WHERE topic_id = ? ORDER BY RAND() LIMIT 10',
      [grade]
    );
for (let question of tableQuestions) {
  const [tableAnswers] = await db.query(
    'SELECT * FROM Answers WHERE question_id = ? ORDER BY RAND() LIMIT 4',
    [question.question_id] 
  );
}
  //res.json({ questions: tableQuestions }, { answers: tableAnswers }); // Show questions to Frontend, *need to display
});
// Must call users before quiz **
router.post('/submit', async (req, res) => { 
  if (req.session.user){ // If user exists: collect submissions
    const questionAnswers = [req.body.Q1, req.body.Q2, req.body.Q3, req.body.Q4, req.body.Q5, req.body.Q6, req.body.Q7, req.body.Q8, req.body.Q9, req.body.Q10];
    // Above is list of question answers submitted by quiz
    // question has : question_id (question number), topic_id (grade), question_text
    // answer has : answer_id (answer number), question_id (question number), answer_text, is_correct (bool) 
    answerCount = 0;
    const correctAnswers = [];
    const incorrectAnswers = [];
    for (let answer of questionAnswers) { // for each question-submission of quiz
      const [mcCorrectAnswers] = await db.query( // The correct multiple choice answer related to question
        'SELECT * FROM answers WHERE question_id = ? AND is_correct = TRUE', 
        // The answer of selected question 
        [answer.question_id] 
      );
      const [questionData] = await db.query( // The correct multiple choice answer related to question
        'SELECT * FROM questions WHERE question_id = ?', 
        // The answer of selected question 
        [answer.question_id] 
      );
      if (answer.answer_id != mcCorrectAnswers[0].answer_id){
        incorrectAnswers.push({
          question_id: answer.question_id,
          answer_id: answer.answer_id,
          answer_text: answer.answer_text, 
          question_text: questionData.question_text
        });
      }
      if (answer.answer_id == mcCorrectAnswers[0].answer_id){
        correctAnswers.push({
          question_id: answer.question_id,
          answer_id: answer.answer_id,
          answer_text: answer.answer_text, 
          question_text: questionData.question_text
        });
        answerCount++;
      }
    }
    console.log(correctAnswers);
    // answerCount / 10 = Final Result of Quiz
    // Frontend needs to Redirect to Results tab
  }
})
module.exports = router;