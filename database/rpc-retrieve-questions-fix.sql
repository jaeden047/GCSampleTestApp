-- Fix retrieve_questions: answer_order can be nested [[a1,a2,a3,a4],...] or flat [a1..a4,a5..a8,...].
-- Uses SECURITY INVOKER so RLS applies (same as before). Handles attempt not found and both formats.

CREATE OR REPLACE FUNCTION retrieve_questions(input_attempt_id int4)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    attempt_data RECORD;
    result_json jsonb := '[]'::jsonb;
    q_row RECORD;
    q_id bigint;
    question_text_val text;
    answer_ids_for_q jsonb;
    answer_order_flat int[];
    answer_record RECORD;
    question_answers jsonb;
    q_idx int;
    is_nested boolean;
BEGIN
    -- Get question_list and answer_order for this attempt
    SELECT question_list, answer_order
    INTO attempt_data
    FROM public.test_attempts
    WHERE attempt_id = input_attempt_id;

    IF NOT FOUND OR attempt_data.question_list IS NULL OR attempt_data.answer_order IS NULL THEN
        RETURN '[]'::jsonb;
    END IF;

    -- Detect format: nested [[],[]] vs flat [...,...] (first element is array vs number)
    is_nested := (jsonb_typeof(attempt_data.answer_order) = 'array'
                  AND jsonb_array_length(attempt_data.answer_order) > 0
                  AND jsonb_typeof(attempt_data.answer_order->0) = 'array');

    -- Loop over questions with index
    FOR q_row IN
        SELECT (ordinality - 1)::int AS idx, (elem::text)::bigint AS question_id
        FROM jsonb_array_elements_text(attempt_data.question_list) WITH ORDINALITY AS t(elem, ordinality)
    LOOP
        q_id := q_row.question_id;
        q_idx := q_row.idx;

        -- Get question text
        SELECT q.question_text INTO question_text_val
        FROM public.questions q
        WHERE q.question_id = q_id;

        IF question_text_val IS NULL THEN
            question_text_val := '';
        END IF;

        -- Build answer_order_flat (int[]) for this question: nested -> one element, flat -> slice of 4
        IF is_nested THEN
            answer_ids_for_q := attempt_data.answer_order->q_idx;
            IF answer_ids_for_q IS NULL OR answer_ids_for_q = 'null'::jsonb OR jsonb_typeof(answer_ids_for_q) != 'array' THEN
                answer_order_flat := ARRAY[]::int[];
            ELSE
                answer_order_flat := ARRAY(
                    SELECT (elem::text)::int
                    FROM jsonb_array_elements_text(answer_ids_for_q) AS elem
                );
            END IF;
        ELSE
            -- Flat: slice positions (q_idx*4+1) .. ((q_idx+1)*4) (1-based ordinality)
            answer_order_flat := ARRAY(
                SELECT (elem::text)::int
                FROM jsonb_array_elements_text(attempt_data.answer_order) WITH ORDINALITY AS t(elem, ord)
                WHERE ord > q_idx * 4 AND ord <= (q_idx + 1) * 4
            );
            IF answer_order_flat IS NULL THEN
                answer_order_flat := ARRAY[]::int[];
            END IF;
        END IF;

        IF array_length(answer_order_flat, 1) IS NULL OR array_length(answer_order_flat, 1) = 0 THEN
            result_json := result_json || jsonb_build_object(
                'question_id', q_id,
                'question_text', question_text_val,
                'answers', '[]'::jsonb
            );
            CONTINUE;
        END IF;

        -- Fetch answers for this question in display order
        question_answers := '[]'::jsonb;
        FOR answer_record IN
            SELECT a.answer_id, a.answer_text
            FROM public.answers a
            WHERE a.question_id = q_id
              AND a.answer_id = ANY(answer_order_flat)
            ORDER BY array_position(answer_order_flat, a.answer_id)
        LOOP
            question_answers := question_answers || jsonb_build_object(
                'answer_id', answer_record.answer_id,
                'answer_text', answer_record.answer_text
            );
        END LOOP;

        -- Append question and its answers to result
        result_json := result_json || jsonb_build_object(
            'question_id', q_id,
            'question_text', question_text_val,
            'answers', question_answers
        );
    END LOOP;

    RETURN result_json;
END;
$$;

COMMENT ON FUNCTION retrieve_questions(int4) IS
  'Returns questions and answers for an attempt. SECURITY INVOKER (RLS applies). Handles nested [[...],[...],...] or flat answer_order.';
