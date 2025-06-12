const express = require('express');
const router = express.Router();
const db = require('../db');
const jwt = require('jsonwebtoken'); // Create user JWToken
/**
 * Route: /users
 * fetch or insert user info db
 * create user JWToken
 * 
 */
router.post('/', async (req, res) => { // asynchronously because route wait for the database to finish before responding to the user
  const { Name, Email, Phone } = req.body;
  console.log(Name);
  console.log(Email);
  console.log(Phone);
  try {
    // 1. Check if user exists. ExistingUser 
    const [existingUser] = await db.query(
      'SELECT * FROM Users WHERE email = ?',
      [Email]
    );
    let user; // store existed or new user info
    if (existingUser.length > 0) {
      user = existingUser[0];
      console.log('User exists:', user);
    } else {
      // 2. Insert new user. Result Declaration
      const result = await db.query(
        'INSERT INTO Users (name, email, phone_number) VALUES (?, ?, ?)',
        [Name, Email, Phone]
      );
      const userId = result.insertId; // userID collects from Database
      user = { user_id: userId, name: Name, email: Email, phone: Phone}; // User data collects from Database
      console.log('New user created:', user); // Declaring the user's new entry
    }
    // 3. Create JWT token
    console.log("user id:", user.user_id);
    const token = jwt.sign(
      { id: user.user_id, name: user.name },
      process.env.JWT_SECRET || 'secret-key',
      { expiresIn: '1h' }
    );

    // 4. Send token back to frontend
    res.status(200).json({ token });
  } catch (err) {
    console.error('Error handling user:', err);
    res.status(500).send('Server error');
  }
});

module.exports = router;

/*
if (response.ok) {
  // Navigate to dashboard after successful login
  router.push('/dashboard');
}
 */
