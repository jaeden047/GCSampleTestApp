-- Add round (local vs final) for Math two-round flow.

ALTER TABLE test_attempts
  ADD COLUMN IF NOT EXISTS round text NOT NULL DEFAULT 'local';


COMMENT ON COLUMN test_attempts.round IS 'For Math topics: local round (current quiz) or final round. Other topics use local only.';
