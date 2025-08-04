var express = require('express');
var router = express.Router();
const db = require('../db');// Review for later
const verifyToken = require('../middleware/verifyJWT'); 
/**
 * GET /pastAttempts
 * - Fetch previous attempt or saved answers
 */
router.get('/pastAttempts', verifyToken, async (req, res) => {
  // const userId = req.session.userId;
  const userId = req.user.id; // pulled from token
  
  if (!userId) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  try {
    const [results] = await db.query(
      'SELECT * FROM TestAttempts WHERE user_id = ? ORDER BY test_date DESC',
      [userId]
    );

    res.json({ results }); // Response.body, pushing from backend.
  } catch (error) {
    console.error('Error fetching results:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
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