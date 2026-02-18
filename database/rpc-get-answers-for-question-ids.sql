-- Returns all answers for the given question_ids so the results page can show every question's
-- options even when RLS on answers would otherwise hide some rows. Uses SECURITY DEFINER so
-- the app receives all needed rows for attempt review.

CREATE OR REPLACE FUNCTION get_answers_for_question_ids(p_question_ids jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result_json jsonb := '[]'::jsonb;
  r RECORD;
BEGIN
  FOR r IN
    SELECT a.answer_id, a.question_id, a.answer_text, a.is_correct
    FROM answers a
    WHERE a.question_id IN (
      SELECT (elem::text)::int
      FROM jsonb_array_elements_text(p_question_ids) AS elem
    )
  LOOP
    result_json := result_json || jsonb_build_object(
      'answer_id', r.answer_id,
      'question_id', r.question_id,
      'answer_text', r.answer_text,
      'is_correct', r.is_correct
    );
  END LOOP;
  RETURN result_json;
END;
$$;

COMMENT ON FUNCTION get_answers_for_question_ids(jsonb) IS
  'Returns all answers for the given question IDs. Used by results page so answers display regardless of RLS on answers.';
