-- Phase 1: Add question_sets and wire questions to sets 
-- Run in order. Adjust topic_id / topic_name if your topics table differs.

-- 1. Create question_sets table
CREATE TABLE IF NOT EXISTS question_sets (
  set_id smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  topic_id smallint NOT NULL REFERENCES topics(topic_id) ON DELETE CASCADE,
  round text NOT NULL,
  set_number smallint NOT NULL,
  time_limit_minutes smallint NOT NULL DEFAULT 30,
  UNIQUE (topic_id, round, set_number)
);

COMMENT ON TABLE question_sets IS 'One row per (topic, round, set_number). Grade categories: sample=1 set, local/final=4 sets each; Plastic: main x 1 set.';

-- 2. Add question_set_id to questions (nullable for migration)
ALTER TABLE questions ADD COLUMN IF NOT EXISTS question_set_id smallint REFERENCES question_sets(set_id) ON DELETE CASCADE;

-- 3. Add question_set_id to test_attempts (which set was used for this attempt)
ALTER TABLE test_attempts ADD COLUMN IF NOT EXISTS question_set_id smallint REFERENCES question_sets(set_id);

-- 4a. Sample quiz: 1 set per grade category (set_number = 1 only)
INSERT INTO question_sets (topic_id, round, set_number, time_limit_minutes)
SELECT topic_id, 'sample', 1, 30
FROM topics
WHERE topic_id IN (1, 3, 4, 5)
ON CONFLICT (topic_id, round, set_number) DO NOTHING;

-- 4b. Local and Final rounds: 4 sets each per grade category (set_number 1-4)
INSERT INTO question_sets (topic_id, round, set_number, time_limit_minutes)
SELECT t.topic_id, r.round, s.n, 30
FROM topics t
CROSS JOIN (VALUES ('local'), ('final')) AS r(round)
CROSS JOIN (VALUES (1), (2), (3), (4)) AS s(n)
WHERE t.topic_id IN (1, 3, 4, 5)
ON CONFLICT (topic_id, round, set_number) DO NOTHING;

-- 5. Insert one set for Plastic Pollution Focus 
INSERT INTO question_sets (topic_id, round, set_number, time_limit_minutes)
SELECT topic_id, 'main', 1, 30 FROM topics WHERE topic_name = 'Plastic Pollution Focus'
ON CONFLICT (topic_id, round, set_number) DO NOTHING;
