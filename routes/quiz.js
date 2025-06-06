const express = require('express');
const db = require('../db');
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
 * - Deal with submission logic
 */

// Setting up a quiz according to the selected Grade
router.post('/', async (req, res) => { 
  const Grade = req.body.grade; // This is the Topic/Grade selected by the user
  if (req.session.user){
    const userId = req.session.user.id;
    // req.session.user.grade = grade; we're not using this global variable

    // Load the quiz with 10 questions
    const [tableQuestions] = await db.query(
      'SELECT * FROM Questions WHERE topic_id = ? ORDER BY RAND() LIMIT 10',
      [Grade]
    );

    const questionIds = []; // Stores question lists to TestAttempts db
    const answerOrder = []; // Stores answer lists to TestAttempts db

    // Acquire the multiple choice options
    for (let question of tableQuestions) {
      const [tableAnswers] = await db.query(
        'SELECT * FROM Answers WHERE question_id = ? ORDER BY RAND() LIMIT 4',
        [question.question_id] 
      );
      question.answers = tableAnswers; // Load answers to frontend
      questionIds.push(question.question_id); // Load questions for database
      answerOrder.push(tableAnswers.map(ans => ans.answer_id)); // Load answers for database
    }

    // Insert into TestAttempts with current user ID
    await db.query(
      `INSERT INTO TestAttempts (user_id, question_list, answer_order, selected_answers, score)
       VALUES (?, ?, ?, ?, ?)`,
      [
        userId,
        JSON.stringify(questionIds),
        JSON.stringify(answerOrder),
        JSON.stringify([]), // selected_answers empty for now
        0 // score sets 0
      ]
    );

    // Send the questions with their randomized answers back to frontend
    res.json({ questions: tableQuestions });
  } else {
    console.log("User not logged in.");
    res.status(401).json({ message: 'Unauthorized' });
  }
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
    for (let answer of questionAnswers) { // For each question-submission of quiz
      const [mcCorrectAnswers] = await db.query( // The correct multiple choice answer related to question
        'SELECT * FROM answers WHERE question_id = ? AND is_correct = TRUE',
        // The answer of selected question
        [answer.question_id]
      );
      const [questionData] = await db.query( // The question itself
        'SELECT * FROM questions WHERE question_id = ?',
        [answer.question_id]
      );
      if (answer.answer_id != mcCorrectAnswers[0].answer_id){
        incorrectAnswers.push({ // pushes to end of the incorrectAnswers array
          question_id: answer.question_id,
          answer_id: answer.answer_id,
          answer_text: answer.answer_text,
          question_text: questionData.question_text
        });
      }
      if (answer.answer_id == mcCorrectAnswers[0].answer_id){
        correctAnswers.push({ // pushes to end of the correctAnswers array
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