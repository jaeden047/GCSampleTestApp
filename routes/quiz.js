const express = require('express');
const router = express.Router();

/**
 * GET /quiz
 * - Get list of quiz topics
 * - Used to show options for the user to choose from
 * - TODO: Query the topics from DB
 */
router.get('/', (req, res) => {
  // TODO: Fetch topic list from DB
  res.json({ topics: [] });
});

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
