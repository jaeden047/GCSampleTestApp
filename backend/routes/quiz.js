const express = require('express');
const db = require('../db');
const router = express.Router();
const verifyToken = require('../middleware/verifyJWT'); // verify JWT and extract user info from the token
// LOGIC TREE
// From users main menu, finish contact info, session declaration -> Go to Quizzes Page -> Select a Quiz
// -> Backend Receives Grade from Quiz Selected -> Fetch Questions from Database based on Grade
// -> User Hits Submit on Quiz -> Results filed into database 'results column' for user -> User checks the results page which collects from column (results.js)
// Test: Does session name stay from users.js? Does multiple users cause intersecting sessions? Is there any way to break the quiz selection

/** 
 * Route: /quiz
 * Fetch questions and answers based on selected Topic
 * Store quiz data to TestAttempts db
 * Deal with submission and score logic
*/

// Setting up a quiz according to the selected Topic
router.post('/', verifyToken, async (req, res) => { 
  const Grade = req.body.grade; // This is the Topic/Grade selected by the user
  const userId = req.user.id; // pulled from token
  console.log('Grade: ', Grade);

  // Load the quiz with 10 questions
  const [tableQuestions] = await db.query(
    'SELECT q.* FROM Questions q JOIN Topics t ON q.topic_id = t.topic_id WHERE t.topic_name = ? ORDER BY RAND() LIMIT 10',
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
  const [result] = await db.query(
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
  const attemptId = result.insertId; // get the attempt_id

  // Send the questions with their randomized answers back to frontend
  res.json({ attempt_id: attemptId, questions: tableQuestions });  
  // Store like this on the frontend
  // const { attempt_id, questions } = await api.post('/api/quiz', { grade });

});

// Post quiz score calculation
router.post('/submit', verifyToken, async (req, res) => {
  const { attempt_id, selected_answers} = req.body;
  const userId = req.user.id; // pulled from token
  // selected_answers is expected to be a list of 10 answer_id

  // For testing: make sure we get 10 answers from frontend
  if (!Array.isArray(selected_answers) || selected_answers.length !== 10) {
    return res.status(400).json({ message: 'Invalid answer format.' });
  }

  // Score calculation from selected answers
  const [rows] = await db.query(
    `SELECT COUNT(*) AS score FROM Answers 
    WHERE answer_id IN (?) AND is_correct = TRUE`,
    [selected_answers]
  ); // Select the rows where answer_id is correct. Count and store in .score
  const score = rows[0].score; // out of 10

  // Update TestAttempts with user's answers and score
  await db.query(
    `UPDATE TestAttempts
     SET selected_answers = ?, score = ?
     WHERE attempt_id = ? AND user_id = ?`,
    [
      JSON.stringify(selected_answers), // these are a list of answer_id
      score,
      attempt_id,
      userId,
    ]
  );

  // Send response to frontend
  res.json({
    message: 'Submission saved successfully.',
    score,
    userId,
    attemptId: attempt_id,
  });
})
module.exports = router;