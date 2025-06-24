// run npm start to start the backend

// Import modules
var createError = require('http-errors');
var path = require('path');
var logger = require('morgan');
require('dotenv').config(); // Load env variables

// Express
const express = require('express');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const app = express();

// Router for handling API requests
const indexRouter = require('./routes');

// Enable CORS globally
app.use(cors({
  origin: "*", // You can change this to your specific web app domain in production
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

// Database connection
require('./db'); // needed to open & access database file

// Server Setup
app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:3000');
});

app.use(express.json()); // for parsing application/json request bodies (req.body)
app.use(express.urlencoded({ extended: true })); // if form sends data -> put data into req.body (requires encoded url tied to front-end submission)
app.use(cookieParser()); // read parser 
app.use(express.static(path.join(__dirname, 'public'))); // serves files from public folder
app.use(logger('dev')); // prints to the dev console ("morgan")

// view engine setup
app.set('views', path.join(__dirname, 'views')); // creates a path to the views folder
app.set('view engine', 'jade'); // sets the view engine to jade so that HTML uses the .jade files

// API route handling
app.use('/api', indexRouter);

// Error Handling
app.use(function(req, res, next) {
  next(createError(404)); // route is not found
});

app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
