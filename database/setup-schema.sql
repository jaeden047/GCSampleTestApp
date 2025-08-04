-- Create Users table
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL, -- user name
  email VARCHAR(100) NOT NULL UNIQUE, -- user authentication
  phone_number VARCHAR(20), -- (optional) to verify their registration to Future Mind Challenges
  registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create Topics table
CREATE TABLE IF NOT EXISTS Topics (
  topic_id INT AUTO_INCREMENT PRIMARY KEY,
  topic_name VARCHAR(100) NOT NULL -- e.q. grade 7, grade 8 or environmental topics
); -- each topic has a book of questions where we randomly select 10 for the quiz

-- Create Questions table
CREATE TABLE IF NOT EXISTS Questions (
  question_id INT AUTO_INCREMENT PRIMARY KEY,
  topic_id INT NOT NULL,
  question_text TEXT NOT NULL,
  FOREIGN KEY (topic_id) REFERENCES Topics(topic_id) ON DELETE CASCADE
);

-- Create Answers table
CREATE TABLE IF NOT EXISTS Answers (
  answer_id INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT NOT NULL,
  answer_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (question_id) REFERENCES Questions(question_id) ON DELETE CASCADE
);

-- Create TestAttempts table
CREATE TABLE IF NOT EXISTS TestAttempts (
  attempt_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  test_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
  question_list JSON, -- list of 10 questions that was randomly selected
  answer_order JSON, -- list of multiple choice answers in its displayed order e.q. "[[21,19,23,20],[24,25,26,27],..." 
  selected_answers JSON, -- the 10 answers that was selected by the user
  score INT,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
