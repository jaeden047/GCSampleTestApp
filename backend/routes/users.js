const express = require('express');
const router = express.Router();
const db = require('../db');
const jwt = require('jsonwebtoken');
// const verifyToken = require('../middleware/auth');
/**
 * Route: /users
 * - POST request user access and initializes session data.
 * - Collect user name, email and phone number(optional)
 */
  // TODO: Create sessions in order to fetch and display user info

  // Error checking (what if session made pre-emptively, how to stop random link upload, how to hard-code transitions between backend)
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
    let user; // Variable later use to store in session
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
      user = { id: userId, name: Name, email: Email, phone: Phone}; // User data collects from Database
      console.log('New user created:', user); // Declaring the user's new entry
    }
    // 3. Create JWT token
    const token = jwt.sign(
      { id: user.id, name: user.name }, // Payload
      process.env.JWT_SECRET || 'secret-key', // Replace with env var in real app
      { expiresIn: '1h' }
    );

      // 4. Send token back to frontend
    // 4. Send token back to frontend
    res.status(200).json({ token });
    // res.json({ token });
    // res.status(200).json({ message: 'Login successful' });

  } catch (err) {
    console.error('Error handling user:', err);
    res.status(500).send('Server error');
  }
});

module.exports = router;


// Frontend should handle like this, if success then redirect to /dashboard:
/**
const response = await fetch('/api/users', {
  method: 'POST',
  body: JSON.stringify({ ...userData })
});

if (response.ok) {
  // Navigate to dashboard after successful login
  router.push('/dashboard');
}
 */
