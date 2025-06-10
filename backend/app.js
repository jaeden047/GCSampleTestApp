// To run from scratch, run node setup.js on terminal after downloading mySQL, readying connection, workbench, etc.
// Then run npm start to test the backend.
var createError = require('http-errors');
var path = require('path');
var logger = require('morgan');

require('dotenv').config(); // Load env variables
const express = require('express');
const cookieParser = require('cookie-parser');

const indexRouter = require('./routes');

const app = express();

app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:3000');
});

app.use(express.json()); // for parsing JSON request bodies

require('./db'); // needed to open & access database file

// view engine setup
app.set('views', path.join(__dirname, 'views')); // creates a path to the views folder
app.set('view engine', 'jade'); // sets the view engine to jade so that HTML uses the .jade files

app.use(logger('dev')); // prints to the dev console
app.use(express.json()); // tells express to receive from the frontend (i.e. req.body = { key: value })
app.use(express.urlencoded({ extended: true })); // if form sends data -> put data into req.body (requires encoded url tied to front-end submission)
app.use(cookieParser()); // read parser 
app.use(express.static(path.join(__dirname, 'public'))); // serves files from public folder


//******  MIGHT ONLY ONE OF THEM */
app.use('/api', indexRouter); // all routes are under /api prefix
app.use('/', indexRouter);

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
