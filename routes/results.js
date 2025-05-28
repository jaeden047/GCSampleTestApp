var express = require('express');
var router = express.Router();
/**
 * GET /results
 * - (Optional) Fetch previous attempt or saved answers
 * - Could be skipped if you’re evaluating in POST only
 * - TODO: Implement only if needed
 */
router.get('/', (req, res) => {
  // TODO: Fetch user's saved answers from DB/session
  res.json({ answers: [] });
});

/**
 * POST /results
 * - Receive submitted answers from user
 * - Evaluate and return score
 * - TODO: Implement quiz grading logic
 */
router.post('/', (req, res) => {
  const { answers } = req.body;
  // TODO: Grade answers, calculate score, save if needed
  res.json({ score: 0, correct: 0 });
});

module.exports = router;
