-- Region-based quiz unlock and set assignment
-- Applies to all math grade categories (Grade 5&6, 7&8, 9&10, 11&12).

-- 1. Add region column to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS region text;

COMMENT ON COLUMN public.profiles.region IS 'Region for quiz set assignment: asia_oceania, africa, americas, europe. Derived from country on signup.';

-- 2. Region -> set_number mapping (Set 1=Asia/Oceania, 2=Africa, 3=Americas, 4=Europe)
CREATE TABLE IF NOT EXISTS public.region_set_mapping (
  region text PRIMARY KEY,
  set_number smallint NOT NULL CHECK (set_number >= 1 AND set_number <= 4)
);

COMMENT ON TABLE public.region_set_mapping IS 'Maps region to question set number for local/final rounds.';

INSERT INTO public.region_set_mapping (region, set_number) VALUES
  ('asia_oceania', 1),
  ('africa', 2),
  ('americas', 3),
  ('europe', 4)
ON CONFLICT (region) DO UPDATE SET set_number = EXCLUDED.set_number;

-- 3. Manual lock/unlock by round and region (applies to ALL grade categories)
CREATE TABLE IF NOT EXISTS public.region_round_unlocks (
  round text NOT NULL,
  region text NOT NULL,
  is_unlocked boolean NOT NULL DEFAULT false,
  PRIMARY KEY (round, region),
  CONSTRAINT region_round_unlocks_region_fkey
    FOREIGN KEY (region) REFERENCES public.region_set_mapping(region)
);

COMMENT ON TABLE public.region_round_unlocks IS 'Admin-controlled. Unlock local/final round for a region via SQL. Applies to all math grade categories.';

-- 4. Seed all 8 rows (2 rounds x 4 regions), all locked initially
INSERT INTO public.region_round_unlocks (round, region, is_unlocked) VALUES
  ('local', 'asia_oceania', false),
  ('local', 'africa', false),
  ('local', 'americas', false),
  ('local', 'europe', false),
  ('final', 'asia_oceania', false),
  ('final', 'africa', false),
  ('final', 'americas', false),
  ('final', 'europe', false)
ON CONFLICT (round, region) DO NOTHING;

-- ============================================================
-- ADMIN QUERIES 
-- ============================================================

-- Unlock local round for Asia/Oceania (all grades):
-- INSERT INTO region_round_unlocks (round, region, is_unlocked)
-- VALUES ('local', 'asia_oceania', true)
-- ON CONFLICT (round, region) DO UPDATE SET is_unlocked = true;

-- Lock local round for Asia/Oceania:
-- UPDATE region_round_unlocks SET is_unlocked = false
-- WHERE round = 'local' AND region = 'asia_oceania';

-- Unlock final round for Africa (all grades):
-- INSERT INTO region_round_unlocks (round, region, is_unlocked)
-- VALUES ('final', 'africa', true)
-- ON CONFLICT (round, region) DO UPDATE SET is_unlocked = true;

-- Lock all regions for local round:
-- UPDATE region_round_unlocks SET is_unlocked = false WHERE round = 'local';

-- ============================================================
-- BACKFILL: Existing users (before region was required at signup)
-- ============================================================
-- All existing users do not have a region. Assign them to North America
-- (americas) since they are all in Canada. From this point onwards, region
-- is required upon signup, so no backfill is needed for future users.
--
-- Run this ONCE after the migration:
-- UPDATE profiles SET region = 'americas' WHERE region IS NULL;
