
-- 1. Delete answers for all questions in the Grade 11 and 12 sample set
DELETE FROM answers
WHERE question_id IN (
  SELECT question_id FROM questions
  WHERE question_set_id = (
    SELECT qs.set_id FROM question_sets qs
    JOIN topics t ON t.topic_id = qs.topic_id
    WHERE t.topic_name = 'Grade 11 and 12'
      AND qs.round = 'sample'
      AND qs.set_number = 1
    LIMIT 1
  )
);

-- 2. Delete questions in the Grade 11 and 12 sample set
DELETE FROM questions
WHERE question_set_id = (
  SELECT qs.set_id FROM question_sets qs
  JOIN topics t ON t.topic_id = qs.topic_id
  WHERE t.topic_name = 'Grade 11 and 12'
    AND qs.round = 'sample'
    AND qs.set_number = 1
  LIMIT 1
);

-- 3. Reset the question_id sequence so the next bulk-insert gets correct IDs (avoids duplicate key)
SELECT setval(
  pg_get_serial_sequence('questions', 'question_id')::regclass,
  (SELECT COALESCE(MAX(question_id), 0) FROM questions)
);
