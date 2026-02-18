-- Delete the "Sample Quiz" topic and ALL related data 
-- Removes: Sample Quiz topic, its questions, their answers, and all test attempts for that topic.

BEGIN;

-- 1. Delete answers that belong to questions in the Sample Quiz topic
DELETE FROM answers
WHERE question_id IN (
  SELECT question_id FROM questions
  WHERE topic_id = (SELECT topic_id FROM topics WHERE topic_name = 'Sample Quiz')
);

-- 2. Delete questions that belong to the Sample Quiz topic
DELETE FROM questions
WHERE topic_id = (SELECT topic_id FROM topics WHERE topic_name = 'Sample Quiz');

-- 3. Delete all test attempts (results) for the Sample Quiz topic
DELETE FROM test_attempts
WHERE topic_id = (SELECT topic_id FROM topics WHERE topic_name = 'Sample Quiz');

-- 4. Delete the Sample Quiz topic row
DELETE FROM topics
WHERE topic_name = 'Sample Quiz';

COMMIT;
