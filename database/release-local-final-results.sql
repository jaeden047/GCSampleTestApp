-- Release Local and Final round results (test attempts + leaderboard)
-- When results_released = true for a math grade topic:
--   - Results overview: Local/Final attempts show score and answers (no longer "Results locked").
--   - Leaderboard: Local/Final round tabs show rankings instead of "Rankings will soon be released by the admin."
-- Sample Quiz is always visible regardless of this flag.
--
-- Uncomment the block you need and run 

-- Release a single grade category (e.g. Grade 11 and 12)
-- UPDATE topics
-- SET results_released = true
-- WHERE topic_name = 'Grade 11 and 12';

-- Release all math grade categories (Grade 5–6, 7–8, 9–10, 11–12)
-- UPDATE topics
-- SET results_released = true
-- WHERE topic_name IN ('Grade 5 and 6', 'Grade 7 and 8', 'Grade 9 and 10', 'Grade 11 and 12');

-- Release Plastic Pollution Focus (if you use results_released for that topic)
-- UPDATE topics
-- SET results_released = true
-- WHERE topic_name = 'Plastic Pollution Focus';


-- Re-lock Local and Final (for testing or if you need to hide results again)
-- Run one of the following, then students see "Results locked" and "Rankings will soon be released" again.

-- Re-lock a single grade
-- UPDATE topics
-- SET results_released = false
-- WHERE topic_name = 'Grade 11 and 12';

-- Re-lock all math grade categories
-- UPDATE topics
-- SET results_released = false
-- WHERE topic_name IN ('Grade 5 and 6', 'Grade 7 and 8', 'Grade 9 and 10', 'Grade 11 and 12');
