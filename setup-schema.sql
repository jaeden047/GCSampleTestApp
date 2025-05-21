-- Create Users table
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create Topics table
CREATE TABLE IF NOT EXISTS Topics (
  topic_id INT AUTO_INCREMENT PRIMARY KEY,
  topic_name VARCHAR(100) NOT NULL
);

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
  test_date DATE NOT NULL,
  test_time TIME NOT NULL,
  score INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
