var express = require('express');
var router = express.Router();
/**
 * GET /results
 * - (Optional) Fetch previous attempt or saved answers
 * - Could be skipped if you’re evaluating in POST only
 * - TODO: Implement only if needed
 */
app.get('/result', async (req, res) => {
  if (!userId) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  try {
    const [results] = await db.query(
      'SELECT * FROM TestAttempts WHERE user_id = ? ORDER BY test_date DESC',
      [userId]
    );

    res.json({ results });
  } catch (error) {
    console.error('Error fetching results:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
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


/**Front end should look something like this to fetch:
 * const fetchResults = async () => {
  const res = await fetch('/result');
  if (res.ok) {
    const data = await res.json();
    console.log(data.results); // your past attempts
  } else {
    console.error('Error:', await res.json());
  }
};
 */