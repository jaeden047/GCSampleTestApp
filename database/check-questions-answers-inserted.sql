-- Check if questions and answers are inserted for a topic/round/set.
-- Change topic_name, round, set_number in the subquery to match what you inserted (e.g. Grade 11 and 12, sample, 1).

-- 1) Summary: total questions and total answers for that set
SELECT
  (SELECT count(*) FROM questions q
   WHERE q.question_set_id = (
     SELECT qs.set_id FROM question_sets qs
     JOIN topics t ON t.topic_id = qs.topic_id
     WHERE t.topic_name = 'Grade 11 and 12' AND qs.round = 'sample' AND qs.set_number = 1
     LIMIT 1
   )) AS total_questions,
  (SELECT count(*) FROM answers a
   WHERE a.question_id IN (
     SELECT q.question_id FROM questions q
     WHERE q.question_set_id = (
       SELECT qs.set_id FROM question_sets qs
       JOIN topics t ON t.topic_id = qs.topic_id
       WHERE t.topic_name = 'Grade 11 and 12' AND qs.round = 'sample' AND qs.set_number = 1
       LIMIT 1
     )
   )) AS total_answers;

-- 2) List each question in that set with its answer count (expect 4 answers per question)
SELECT
  q.question_id,
  q.question_set_id,
  left(q.question_text, 100) || CASE WHEN length(q.question_text) > 100 THEN '...' ELSE '' END AS question_preview,
  (SELECT count(*) FROM answers a WHERE a.question_id = q.question_id) AS answer_count
FROM questions q
WHERE q.question_set_id = (
  SELECT qs.set_id FROM question_sets qs
  JOIN topics t ON t.topic_id = qs.topic_id
  WHERE t.topic_name = 'Grade 11 and 12' AND qs.round = 'sample' AND qs.set_number = 1
  LIMIT 1
)
ORDER BY q.question_id;
