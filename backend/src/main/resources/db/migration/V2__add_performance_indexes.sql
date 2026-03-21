-- =====================================================
-- V2: Performance indexes for AI features
-- =====================================================
-- These indexes target columns most frequently filtered by:
-- - ExerciseSelectorImpl (AI plan materialization)
-- - RecommendationServiceImpl (exercise recommendations)
-- - ExerciseServiceImpl (browse/filter endpoints)
-- - ExerciseAPIServiceImpl (fallback queries)
--
-- For existing databases where Hibernate already created the
-- tables without indexes. On fresh databases, JPA @Index
-- annotations on the entity classes will also create them.
-- =====================================================

-- Exercise table: 3 most common filter columns
CREATE INDEX IF NOT EXISTS idx_exercise_difficulty
    ON exercise (difficulty_level);

CREATE INDEX IF NOT EXISTS idx_exercise_type
    ON exercise (exercise_type);

CREATE INDEX IF NOT EXISTS idx_exercise_equipment_cat
    ON exercise (equipment_category);

-- Muscle group table: category is used by ExerciseSelector
CREATE INDEX IF NOT EXISTS idx_muscle_group_category
    ON muscle_group (category);

-- Join table indexes for faster exercise-by-muscle-group lookups
-- (the FK columns may already have auto-generated indexes on some
-- MySQL versions, but explicit indexes guarantee it)
CREATE INDEX IF NOT EXISTS idx_emg_muscle_group_id
    ON exercise_muscle_group (muscle_group_id);

CREATE INDEX IF NOT EXISTS idx_emg_exercise_id
    ON exercise_muscle_group (exercise_id);

-- Join table indexes for exercise-by-equipment lookups
CREATE INDEX IF NOT EXISTS idx_ee_equipment_id
    ON exercise_equipment (equipment_id);

CREATE INDEX IF NOT EXISTS idx_ee_exercise_id
    ON exercise_equipment (exercise_id);
