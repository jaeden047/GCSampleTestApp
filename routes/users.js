const express = require('express');
const router = express.Router();
const db = require('../db');

/**
 * Route: /users
 * - POST request user access and initializes session data.
 * - Collect user name, email and phone number(optional)
 */
  // TODO: Create sessions in order to fetch and display user info

router.post('/', async (req, res) => { // asynchronously because route wait for the database to finish before responding to the user
  const { Name, Email, Phone } = req.body;

  try {
    // 1. Check if user exists
    const [existingUser] = await db.query(
      'SELECT * FROM Users WHERE email = ?',
      [Email]
    );

    let user;
    if (existingUser.length > 0) {
      user = existingUser[0];
      console.log('User exists:', user);
    } else {
      // 2. Insert new user
      const result = await db.query(
        'INSERT INTO Users (name, email, phone_number) VALUES (?, ?, ?)',
        [Name, Email, Phone]
      );
      const userId = result.insertId;
      user = { id: userId, name: Name, email: Email, phone: Phone};
      console.log('New user created:', user);
    }

    // 3. Store in session
    req.session.user = {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone
    };

    // 4. Respond with success (Frontend can later redirect to dashboard)
    res.status(200).json({ message: 'Login successful' });

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
