-- Results release control: admin can hide score/answers/attempts/leaderboard until ready.
--
-- Behaviour:
-- - Sample Quiz (topic_name = 'Sample Quiz'): is_sample_quiz = true -> students always see score, answers, attempts, leaderboard.
-- - All other topics: results_released = false by default -> students see "Results locked" / "Rankings when released" until you set results_released = true.
-- - When all time windows are done, run: UPDATE topics SET results_released = true WHERE topic_name = ' Our Topic Name';

ALTER TABLE topics
  ADD COLUMN IF NOT EXISTS results_released boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_sample_quiz boolean NOT NULL DEFAULT false;

-- Mark the Sample Quiz (Math) so students always see its results
UPDATE topics
SET is_sample_quiz = true
WHERE topic_name = 'Sample Quiz';

