-- Insert user (Emily Chang, no phone number)
INSERT INTO Users (name, email) VALUES ('Emily Chang', 'emily0109.ec@gmail.com');

-- Insert topic (Grade 8 Math)
INSERT INTO Topics (topic_name) VALUES ('Grade 8 Math');

-- Insert questions and answers
-- Assume topic_id = 1 for Grade 8 Math

-- Question 1
INSERT INTO Questions (topic_id, question_text)
VALUES (1, 'Factorize completely: x² - 4y²');
INSERT INTO Answers (question_id, answer_text, is_correct)
VALUES 
  (1, '(x+2y)(x-2y)', TRUE),
  (1, '(x+y)(x-y)', FALSE),
  (1, '(2x+y)(2x-y)', FALSE),
  (1, '(x+y)²', FALSE);

-- Question 2
INSERT INTO Questions (topic_id, question_text)
VALUES (1, 'If f(x) = 2x² - 3x + 1, what is f(-2)?');
INSERT INTO Answers (question_id, answer_text, is_correct)
VALUES 
  (2, '11', TRUE),
  (2, '13', FALSE),
  (2, '15', FALSE),
  (2, '17', FALSE);

-- Question 3
INSERT INTO Questions (topic_id, question_text)
VALUES (1, 'Solve: 3(2x - 4) = 2(3x + 1)');
INSERT INTO Answers (question_id, answer_text, is_correct)
VALUES 
  (3, 'x = 11', TRUE),
  (3, 'x = -11', FALSE),
  (3, 'x = 14', FALSE),
  (3, 'x = -14', FALSE);

-- Question 4
INSERT INTO Questions (topic_id, question_text)
VALUES (1, 'Which equation represents a line parallel to y = 3x - 4?');
INSERT INTO Answers (question_id, answer_text, is_correct)
VALUES 
  (4, 'y = 3x + 2', TRUE),
  (4, 'y = -3x + 1', FALSE),
  (4, 'y = 1/3x - 1', FALSE),
  (4, 'y = -1/3x + 5', FALSE);

-- Question 5
INSERT INTO Questions (topic_id, question_text)
VALUES (1, 'Simplify: (2x^3y^2)(3xy^4)');
INSERT INTO Answers (question_id, answer_text, is_correct)
VALUES 
  (5, '6x^4y^5', TRUE),
  (5, '6x^3y^5', FALSE),
  (5, '5x^4y^5', FALSE),
  (5, '5x^3y^5', FALSE);