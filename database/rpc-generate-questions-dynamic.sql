-- Run this entire script in Supabase SQL Editor (not the Function editor form).
CREATE OR REPLACE FUNCTION generate_questions(
  topic_input text,
  p_round text DEFAULT 'local',
  p_set_number smallint DEFAULT 1
)
RETURNS jsonb
AS $func$
DECLARE
  v_topic_id smallint;
  v_set_id smallint;
  question_ids jsonb := '[]';
  q record;
BEGIN
  -- Resolve topic name to topic_id (case-insensitive, trimmed)
  SELECT topic_id INTO v_topic_id
  FROM topics
  WHERE lower(trim(topic_name)) = lower(trim(topic_input))
  LIMIT 1;

  IF v_topic_id IS NULL THEN
    RAISE EXCEPTION 'Topic not found: %', topic_input;
  END IF;

  -- Resolve (topic_id, round, set_number) -> set_id
  SELECT set_id INTO v_set_id
  FROM question_sets
  WHERE topic_id = v_topic_id
    AND round = p_round
    AND set_number = p_set_number
  LIMIT 1;

  -- Fallback: Plastic Pollution uses round='main', so if caller used default 'local' and no set found, try 'main'
  IF v_set_id IS NULL AND p_round = 'local' AND p_set_number = 1 THEN
    SELECT set_id INTO v_set_id
    FROM question_sets
    WHERE topic_id = v_topic_id AND round = 'main' AND set_number = 1
    LIMIT 1;
  END IF;

  IF v_set_id IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  -- Collect ALL question IDs for this set (no limit), in random order
  FOR q IN
    SELECT question_id
    FROM questions
    WHERE question_set_id = v_set_id
    ORDER BY random()
  LOOP
    question_ids := question_ids || to_jsonb(q.question_id::int);
  END LOOP;

  -- Fallback for topics (e.g. Plastic Pollution) whose questions still use topic_id only (not yet linked to question_set_id)
  IF question_ids = '[]'::jsonb THEN
    FOR q IN
      SELECT question_id
      FROM questions
      WHERE topic_id = v_topic_id
      ORDER BY random()
    LOOP
      question_ids := question_ids || to_jsonb(q.question_id::int);
    END LOOP;
  END IF;

  RETURN question_ids;
END;
$func$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_questions(text, text, smallint) IS
  'Returns all question_id in the question set for (topic_input, p_round, p_set_number). Used for local/final rounds; sample round loads questions in-app from question_sets + questions.';

-- Optional args: p_round (default 'local'), p_set_number (default 1). Returns ALL questions in that set (no limit).
