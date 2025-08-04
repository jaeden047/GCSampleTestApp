const jwt = require('jsonwebtoken');
require('dotenv').config(); // JWT_SECRET key is stored here

// Verify JWT and extract user info from the token
function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader?.split(' ')[1]; // Get after "Bearer"

  if (!token) return res.status(401).json({ message: 'Token missing' });

  jwt.verify(token, process.env.JWT_SECRET || 'secret-key', (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid token' });
    req.user = user; // Attach user info to request
    console.log('✅ Decoded Token:', user);  // Debug checking user token
    next();
  });
}

module.exports = verifyToken;
