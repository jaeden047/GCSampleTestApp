// To run from scratch, run node setup.js on terminal after downloading mySQL, readying connection, workbench, etc.
// Then run npm start to test the backend.
var createError = require('http-errors');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const session = require('express-session');

const express = require('express');
const app = express();
const routes = require('./routes');

app.use(express.json()); // for parsing JSON request bodies
app.use('/api', routes); // all routes are under /api prefix

require('./db'); // needed to open & access database file

// view engine setup
app.set('views', path.join(__dirname, 'views')); // creates a path to the views folder
app.set('view engine', 'jade'); // sets the view engine to jade so that HTML uses the .jade files

app.use(logger('dev')); // prints to the dev console
app.use(express.json()); // tells express to receive from the frontend (i.e. req.body = { key: value })
app.use(express.urlencoded({ extended: true })); // if form sends data -> put data into req.body (requires encoded url tied to front-end submission)
app.use(cookieParser()); // read parser 
app.use(express.static(path.join(__dirname, 'public'))); // serves files from public folder

app.use(session({
  secret: process.env.SESSION_SECRET, // should be stored in env variable
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false } // set to true if using HTTPS
}));

// app.use('/', indexRouter); 
// // indexRouter : '/' as req -> no strip occur -> indexRouter checks router.get('/') 
// // i.e. indexRouter receives '/about' -> no strip occur -> indexRouter checks /routes/index -> indexRouter checks router.get('/about') -> Match
// app.use('/users', usersRouter);
//  // usersRouter : /users as req -> strips '/users' to '/' -> usersRouter checks router.get('/')
//  // Express strips only when prefix more than / in app.use().
// app.use('/form', formRouter); 
//  // formRouter : /form as req -> strips '/form' -> formRouter checks through router commands.

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
