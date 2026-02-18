-- Run in Supabase SQL Editor to inspect one attempt's answer_order structure.
-- Replace 224 with your attempt_id. Results appear in the Results tab (not just Messages).

-- 1) Summary row: confirms the attempt exists and shows lengths + first element type
SELECT
  t.attempt_id,
  t.topic_id,
  t.round,
  jsonb_array_length(t.question_list)     AS question_list_len,
  jsonb_array_length(t.answer_order)      AS answer_order_len,
  jsonb_typeof(t.answer_order->0)         AS first_elem_type
FROM test_attempts t
WHERE t.attempt_id = 224;

-- 2) Per-question breakdown: one row per question index (0-based)
SELECT
  t.attempt_id,
  (ord - 1)::int                          AS question_idx,
  jsonb_typeof(a.elem)                    AS elem_type,
  CASE
    WHEN jsonb_typeof(a.elem) = 'array' THEN (jsonb_array_length(a.elem))::text || ' elements'
    ELSE a.elem::text
  END                                     AS elem_info
FROM test_attempts t
CROSS JOIN LATERAL jsonb_array_elements(t.answer_order) WITH ORDINALITY AS a(elem, ord)
WHERE t.attempt_id = 224
ORDER BY ord;

-- 3) Answers per question: for each question_id in this attempt, how many rows in answers table?
-- If answer_count is 0 for any question, that question will show "no answers" in the app.
SELECT
  t.attempt_id,
  (ord - 1)::int                          AS question_idx,
  (q.elem::text)::int                     AS question_id,
  (SELECT count(*) FROM answers a WHERE a.question_id = (q.elem::text)::int) AS answer_count
FROM test_attempts t
CROSS JOIN LATERAL jsonb_array_elements(t.question_list) WITH ORDINALITY AS q(elem, ord)
WHERE t.attempt_id = 224
ORDER BY ord;
