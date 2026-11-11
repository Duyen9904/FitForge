erDiagram
    %% =====================================================================
    %% PART 1: USER, AUTH & NOTIFICATIONS
    %% =====================================================================
    user {
        BIGINT user_id PK
        VARCHAR_50 username UK "NOT NULL, uk_user_username"
        VARCHAR_100 email UK "NOT NULL, uk_user_email"
        VARCHAR_255 password_hash "NOT NULL"
        DATE date_of_birth
        VARCHAR_20 gender
        FLOAT height_cm
        FLOAT current_weight_kg
        FLOAT target_weight_kg
        VARCHAR_50 fitness_level
        VARCHAR role "NOT NULL (USER, ADMIN)"
        BIGINT primary_goal_id FK "goal.goal_id"
        BOOLEAN onboarding_completed "NOT NULL, default false"
    }

    user_preference {
        BIGINT preference_id PK
        BIGINT user_id FK "NOT NULL, UNIQUE, uk_user_preference_user"
        BOOLEAN notification_enabled "NOT NULL, default true"
        VARCHAR_100 workout_reminder_days
        INT daily_calorie_target
        FLOAT daily_protein_target_g
        FLOAT daily_carbs_target_g
        FLOAT daily_fats_target_g
    }

    refresh_token {
        BIGINT id PK
        VARCHAR_255 token UK "NOT NULL, idx_refresh_token_token"
        BIGINT user_id FK "NOT NULL, user.user_id"
        TIMESTAMP expires_at "NOT NULL"
        TIMESTAMP created_at "NOT NULL"
        VARCHAR_255 session_id
    }

    device_token {
        BIGINT device_token_id PK
        BIGINT user_id FK "NOT NULL, idx_device_token_user"
        VARCHAR_500 token UK "NOT NULL, uk_device_token, idx_device_token_token"
        VARCHAR_50 device_type "ANDROID, IOS, WEB"
        BOOLEAN is_active "NOT NULL, default true"
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    notification {
        BIGINT notification_id PK
        BIGINT user_id FK "NOT NULL, idx_notification_user, idx_notification_user_read"
        VARCHAR_50 notification_type "NOT NULL (WORKOUT_REMINDER, STREAK, GOAL_PROGRESS, MISSED_WORKOUT)"
        VARCHAR_200 title "NOT NULL"
        VARCHAR_1000 message "NOT NULL"
        TEXT data "JSON context"
        BOOLEAN is_read "NOT NULL, default false"
        BOOLEAN is_acted_upon "NOT NULL, default false"
        TIMESTAMP scheduled_for
        BIGINT reference_id
        VARCHAR_50 reference_type
        TIMESTAMP created_at "NOT NULL, idx_notification_created"
        TIMESTAMP updated_at "NOT NULL"
    }

    %% =====================================================================
    %% PART 2: ONBOARDING & GOALS
    %% =====================================================================
    goal {
        BIGINT goal_id PK
        VARCHAR_100 goal_name UK "NOT NULL, uk_goal_name"
        VARCHAR_500 description
        %% Slimfit, Athletic, and Bodybuilding
    }

    onboarding_flows {
        BIGINT id PK
        VARCHAR_50 flow_key "NOT NULL, uk_onboarding_flow_key_version(flow_key, version)"
        VARCHAR_100 name "NOT NULL"
        INT version "NOT NULL, default 1"
        BOOLEAN is_active "NOT NULL, default true"
    }

    onboarding_steps {
        BIGINT id PK
        BIGINT flow_id FK "NOT NULL, onboarding_flows.id, uk_onboarding_step_flow_key(flow_id, step_key)"
        VARCHAR_50 step_key "NOT NULL, uk_onboarding_step_flow_key(flow_id, step_key)"
        VARCHAR_100 title "NOT NULL"
        INT sequence "NOT NULL"
        BOOLEAN is_required "NOT NULL, default true"
        JSON config "stepType, inputType, subtitle, helpText, iconUrl, isActive, options[]"
    }

    user_onboardings {
        BIGINT id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        BIGINT flow_id FK "NOT NULL, onboarding_flows.id"
        VARCHAR_20 status "NOT NULL, default IN_PROGRESS (IN_PROGRESS, COMPLETED, ABANDONED)"
        BIGINT current_step_id FK "onboarding_steps.id (nullable)"
        DATETIME started_at "NOT NULL"
        DATETIME completed_at
    }

    user_onboarding_steps {
        BIGINT onboarding_id PK, FK "NOT NULL, user_onboardings.id"
        BIGINT step_id PK, FK "NOT NULL, onboarding_steps.id"
        VARCHAR_20 status "NOT NULL, default PENDING (PENDING, COMPLETED, SKIPPED)"
        JSON answer_data "JSON user response"
        DATETIME started_at
        DATETIME completed_at
        DATETIME updated_at "NOT NULL"
    }

    %% =====================================================================
    %% PART 3: BODY MEASUREMENTS & PROGRESS PHOTOS
    %% =====================================================================
    user_measurement {
        BIGINT measurement_id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        DATE measurement_date "NOT NULL"
        FLOAT weight_kg
        FLOAT body_fat_percentage
        FLOAT chest_cm
        FLOAT waist_cm
        FLOAT hips_cm
        FLOAT biceps_cm
        FLOAT thighs_cm
        FLOAT skeletal_muscle_mass "InBody SMM (kg)"
        FLOAT body_fat_mass "InBody BFM (kg)"
        FLOAT body_water_liters "InBody TBW (L)"
        INT basal_metabolic_rate "InBody BMR (kcal)"
        INT visceral_fat_level "InBody (1-20)"
        FLOAT waist_hip_ratio "InBody WHR"
        INT in_body_score "InBody (0-100)"
        VARCHAR_20 source "MANUAL, INBODY_IMPORT"
        VARCHAR_500 notes
    }

    measurement_goal {
        BIGINT goal_id PK
        BIGINT user_id FK "NOT NULL, UNIQUE, uk_measurement_goal_user"
        FLOAT target_weight_kg
        FLOAT target_body_fat_percentage
        FLOAT target_chest_cm
        FLOAT target_waist_cm
        FLOAT target_hips_cm
        FLOAT target_biceps_cm
        FLOAT target_thighs_cm
        DATE target_date
        BOOLEAN is_active "NOT NULL, default true"
        VARCHAR_500 notes
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    progress_photo {
        BIGINT photo_id PK
        BIGINT user_id FK "NOT NULL, idx_progress_photo_user"
        DATE photo_date "NOT NULL, idx_progress_photo_date"
        VARCHAR_500 photo_url "NOT NULL"
        VARCHAR_50 category "front, side, back"
        VARCHAR_500 notes
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    %% =====================================================================
    %% PART 4: EXERCISE & REFERENCE LIBRARY
    %% =====================================================================
    muscle_group {
        BIGINT muscle_group_id PK
        VARCHAR_100 group_name UK "NOT NULL, uk_muscle_group_name"
        VARCHAR_50 category "idx_muscle_group_category"
        VARCHAR_500 description
        INT recovery_days_needed
        VARCHAR_500 image_url
    }

    equipment {
        BIGINT equipment_id PK
        VARCHAR_100 equipment_name UK "NOT NULL, uk_equipment_name"
        VARCHAR_50 equipment_type
        VARCHAR_500 description
        VARCHAR_500 image_url
    }

    exercise {
        VARCHAR_50 exercise_id PK
        VARCHAR_100 exercise_name UK "NOT NULL, uk_exercise_name"
        VARCHAR_1000 description
        VARCHAR_50 difficulty_level "idx_exercise_difficulty"
        VARCHAR_50 exercise_type "idx_exercise_type"
        VARCHAR_2000 instructions
        VARCHAR_255 video_url
        VARCHAR_255 image_url
        INT calories_burned_per_min
        VARCHAR_2000 tips
        BOOLEAN requires_spotter "NOT NULL, default false"
        VARCHAR_50 equipment_category "idx_exercise_equipment_cat"
    }

    exercise_muscle_group {
        BIGINT id PK
        VARCHAR_50 exercise_id FK "NOT NULL, uk_exercise_muscle_group(exercise_id, muscle_group_id)"
        BIGINT muscle_group_id FK "NOT NULL, uk_exercise_muscle_group(exercise_id, muscle_group_id)"
        VARCHAR_50 intensity_level
        BOOLEAN is_primary "NOT NULL, default false"
    }

    exercise_equipment {
        BIGINT id PK
        VARCHAR_50 exercise_id FK "NOT NULL, uk_exercise_equipment(exercise_id, equipment_id)"
        BIGINT equipment_id FK "NOT NULL, uk_exercise_equipment(exercise_id, equipment_id)"
        BOOLEAN is_required "NOT NULL, default true"
        VARCHAR_500 usage_notes
    }

    exercise_alternative {
        BIGINT alternative_id PK
        VARCHAR_50 original_exercise_id FK "NOT NULL, uk_exercise_alternative(original, alternative)"
        VARCHAR_50 alternative_exercise_id FK "NOT NULL, uk_exercise_alternative(original, alternative)"
        VARCHAR_500 reason
        VARCHAR_50 substitution_type
    }

    workout_template {
        BIGINT template_id PK
        VARCHAR_100 name "NOT NULL"
        VARCHAR_500 description
        VARCHAR_50 goal_type "NOT NULL"
        VARCHAR_50 experience_level "NOT NULL"
        VARCHAR_255 equipment_tags "comma-separated"
        INT days_per_week "NOT NULL"
        VARCHAR_50 intensity_level
        VARCHAR_255 primary_muscle_groups "comma-separated"
        VARCHAR_255 contraindications "comma-separated"
        TEXT metadata
        BOOLEAN is_active "NOT NULL, default true"
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    %% =====================================================================
    %% PART 5: WORKOUT PLANNING & EXECUTION
    %% =====================================================================
    workout_plan {
        BIGINT plan_id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        BIGINT goal_id FK "NOT NULL, goal.goal_id"
        BIGINT muscle_group_id FK "NOT NULL, muscle_group.muscle_group_id"
        VARCHAR_100 plan_name "NOT NULL"
        VARCHAR_500 description
        INT frequency_per_week "NOT NULL"
        INT duration_weeks "NOT NULL"
        VARCHAR_255 difficulty_level "NOT NULL"
        VARCHAR_50 algorithm_version
        VARCHAR_50 generated_from
        INT version "NOT NULL, default 1"
        VARCHAR_500 recommendation_reason
        BOOLEAN ai_generated "NOT NULL, default false"
        BOOLEAN allow_workout_swaps "NOT NULL, default true"
        BOOLEAN is_active "NOT NULL, default true"
        VARCHAR_20 generation_strategy "default MANUAL (MANUAL, AI, RULE_BASED)"
        DATE start_date "NOT NULL"
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    workout_plan_scheduled_date {
        BIGINT plan_id FK "NOT NULL, workout_plan.plan_id"
        DATE scheduled_date
        INT list_order "OrderColumn"
    }

    workout_session {
        BIGINT session_id PK
        BIGINT plan_id FK "NOT NULL, workout_plan.plan_id"
        VARCHAR_100 session_name "NOT NULL"
        INT day_number "NOT NULL"
        VARCHAR_100 focus_area
        INT estimated_duration
        VARCHAR_500 warm_up_notes
        VARCHAR_500 cool_down_notes
        BOOLEAN is_rest_day "NOT NULL, default false"
        DATE scheduled_date
    }

    session_exercise {
        BIGINT session_exercise_id PK
        BIGINT session_id FK "NOT NULL, workout_session.session_id"
        VARCHAR_50 exercise_id FK "NOT NULL, exercise.exercise_id"
        INT sets "NOT NULL"
        INT repetitions "NOT NULL"
        FLOAT weight_kg
        INT rest_time_seconds
        INT order_index "NOT NULL"
        VARCHAR_500 notes
        BOOLEAN is_superset "NOT NULL, default false"
    }

    workout_progress {
        BIGINT progress_id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        BIGINT plan_id FK "NOT NULL, workout_plan.plan_id"
        BIGINT session_id FK "NOT NULL, workout_session.session_id"
        TIMESTAMP workout_date "NOT NULL"
        TIMESTAMP start_time
        TIMESTAMP end_time
        INT duration_minutes
        BOOLEAN completed "NOT NULL, default false"
        VARCHAR_1000 performance_notes
        INT difficulty_rating
        INT calories_burned
        FLOAT average_heart_rate
        VARCHAR_20 mood_rating
        VARCHAR_500 proof_photo_url
    }

    exercise_log {
        BIGINT log_id PK
        BIGINT progress_id FK "NOT NULL, workout_progress.progress_id"
        VARCHAR_50 exercise_id FK "NOT NULL, exercise.exercise_id"
        INT set_number "NOT NULL"
        INT repetitions_completed
        FLOAT weight_used_kg
        INT rest_time_seconds
        BOOLEAN completed "NOT NULL, default false"
        VARCHAR_500 notes
    }

    workout_session_log {
        BIGINT session_log_id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        BIGINT workout_plan_id FK "workout_plan.plan_id (nullable)"
        BIGINT workout_progress_id FK "workout_progress.progress_id (nullable)"
        TIMESTAMP performed_at "NOT NULL"
        FLOAT completion_rate "0.0 - 1.0"
        FLOAT avg_rpe "1.0 - 10.0"
        VARCHAR_255 skipped_exercises "comma-separated IDs"
        BOOLEAN auto_adjusted "NOT NULL, default false"
        INT session_rating "1 - 5"
        VARCHAR_1000 notes
        VARCHAR_500 proof_photo_url
    }

    exercise_performance_log {
        BIGINT performance_log_id PK
        BIGINT session_log_id FK "NOT NULL, workout_session_log.session_log_id"
        VARCHAR_50 exercise_id FK "NOT NULL, exercise.exercise_id"
        INT sets_completed
        VARCHAR_100 reps_per_set "comma-separated"
        VARCHAR_100 weight_per_set "comma-separated"
        VARCHAR_100 rpe_per_set "comma-separated"
        BOOLEAN pain_flag "NOT NULL, default false"
        INT failed_reps
        VARCHAR_500 notes
    }

    %% =====================================================================
    %% PART 6: NUTRITION PLANNING & MEAL LOGGING
    %% =====================================================================
    nutrition_plan {
        BIGINT nutrition_plan_id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        BIGINT goal_id FK "goal.goal_id (nullable)"
        VARCHAR_100 plan_name "NOT NULL"
        INT daily_calorie_target
        FLOAT protein_percentage
        FLOAT carbs_percentage
        FLOAT fats_percentage
        INT cheat_meals_per_week
        VARCHAR_50 algorithm_version
        INT version "NOT NULL, default 1"
        VARCHAR_500 recommendation_reason
        BOOLEAN auto_adjust_enabled "NOT NULL, default false"
        BOOLEAN is_active "NOT NULL, default true"
        INT total_days
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    nutrition_day {
        BIGINT nutrition_day_id PK
        BIGINT nutrition_plan_id FK "NOT NULL, uk_nutrition_day_plan_day(nutrition_plan_id, day_number)"
        INT day_number "NOT NULL, uk_nutrition_day_plan_day(nutrition_plan_id, day_number)"
        VARCHAR_100 day_name
        VARCHAR_500 description
        INT target_calories
        BOOLEAN is_rest_day "NOT NULL, default false"
    }

    meal_template {
        BIGINT meal_template_id PK
        BIGINT nutrition_plan_id FK "nutrition_plan.nutrition_plan_id (nullable)"
        BIGINT user_id FK "user.user_id (nullable)"
        VARCHAR_20 source "NOT NULL, default SYSTEM (SYSTEM, USER)"
        VARCHAR_100 meal_name "NOT NULL"
        VARCHAR_50 meal_type
        VARCHAR_500 description
        INT calories
        FLOAT protein_g
        FLOAT carbs_g
        FLOAT fats_g
        VARCHAR_2000 recipe_instructions
    }

    day_meal {
        BIGINT day_meal_id PK
        BIGINT nutrition_day_id FK "NOT NULL, idx_day_meal_day"
        BIGINT meal_template_id FK "NOT NULL, meal_template.meal_template_id"
        VARCHAR_50 meal_type "BREAKFAST, LUNCH, DINNER, SNACK"
        INT order_index "NOT NULL"
        INT custom_calories
        FLOAT custom_protein_g
        FLOAT custom_carbs_g
        FLOAT custom_fats_g
        VARCHAR_500 notes
        VARCHAR_500 proof_photo_url
        TIMESTAMP completed_at
    }

    plan_meal {
        BIGINT plan_meal_id PK
        BIGINT user_id FK "NOT NULL, idx_plan_meal_user_date(user_id, scheduled_date)"
        BIGINT nutrition_plan_id FK "idx_plan_meal_plan_date(nutrition_plan_id, scheduled_date)"
        BIGINT meal_template_id FK "meal_template.meal_template_id (nullable)"
        DATE scheduled_date "NOT NULL"
        VARCHAR_50 meal_type "BREAKFAST, LUNCH, DINNER, SNACK"
        VARCHAR_20 status "NOT NULL, default PLANNED (PLANNED, COMPLETED, SKIPPED), idx_plan_meal_status"
        VARCHAR_20 source "NOT NULL, default MANUAL (MANUAL, TEMPLATE, RCM, AI)"
        VARCHAR_200 food_name "NOT NULL"
        INT calories
        FLOAT protein_g
        FLOAT carbs_g
        FLOAT fats_g
        TIMESTAMP meal_time
        TIMESTAMP completed_at
        BOOLEAN is_cheat_meal "NOT NULL, default false"
        FLOAT adherence_score "0.0 - 1.0"
        VARCHAR_500 notes
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    %% =====================================================================
    %% PART 7: MISSED WORKOUTS, CHEAT MEALS & COMPENSATION
    %% =====================================================================
    missed_workout {
        BIGINT missed_workout_id PK
        BIGINT user_id FK "NOT NULL, user.user_id"
        BIGINT plan_id FK "NOT NULL, workout_plan.plan_id"
        BIGINT session_id FK "NOT NULL, workout_session.session_id"
        DATE scheduled_date "NOT NULL"
        DATE missed_date
        VARCHAR_500 reason
        VARCHAR_500 replan_strategy
        BOOLEAN is_replanned "NOT NULL, default false"
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    cheat_meal_log {
        BIGINT cheat_meal_log_id PK
        BIGINT plan_meal_id FK "NOT NULL, UNIQUE, uk_cheat_meal_log_plan_meal"
        BIGINT user_id FK "NOT NULL, idx_cheat_meal_log_user, idx_cheat_meal_log_user_date"
        DATE cheat_date "NOT NULL, idx_cheat_meal_log_date"
        INT excess_calories
        VARCHAR_500 compensation_strategy
        BOOLEAN is_compensated "NOT NULL, default false"
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    compensation_action {
        BIGINT compensation_id PK
        BIGINT cheat_meal_log_id FK "idx_compensation_action_cheat_meal (nullable)"
        BIGINT missed_workout_id FK "idx_compensation_action_missed_workout (nullable)"
        VARCHAR_20 status "NOT NULL, default PENDING (PENDING, ACTIVE, COMPLETED, EXPIRED, CANCELLED), idx_compensation_action_status"
        VARCHAR_50 action_type "NOT NULL"
        VARCHAR_1000 action_description
        DATE scheduled_date "idx_compensation_action_scheduled"
        DATE valid_until_date
        BOOLEAN is_completed "NOT NULL, default false"
        INT calorie_adjustment
        VARCHAR_500 details
        TIMESTAMP activated_at
        TIMESTAMP completed_at
        INT effectiveness_rating "1 - 5"
        VARCHAR_500 user_feedback
        VARCHAR_30 reschedule_reason "USER_INITIATED, MISSED_WORKOUT, SYSTEM_DEFAULT"
        TIMESTAMP created_at "NOT NULL"
        TIMESTAMP updated_at "NOT NULL"
    }

    makeup_workout {
        BIGINT makeup_id PK
        BIGINT compensation_action_id FK "NOT NULL, UNIQUE, uk_makeup_workout_compensation"
        BIGINT original_session_id FK "NOT NULL, workout_session.session_id"
        BIGINT replacement_session_id FK "workout_session.session_id (nullable)"
        DATE scheduled_makeup_date "NOT NULL"
        VARCHAR_50 adjustment_type
        VARCHAR_500 adjustment_notes
        BOOLEAN is_completed "NOT NULL, default false"
    }

    nutrition_adjustment {
        BIGINT adjustment_id PK
        BIGINT nutrition_plan_id FK "NOT NULL, nutrition_plan.nutrition_plan_id"
        BIGINT compensation_action_id FK "compensation_action.compensation_id (nullable)"
        DATE adjustment_date "NOT NULL"
        DATE valid_until_date
        INT calorie_adjustment
        VARCHAR_500 adjustment_reason
        VARCHAR_1000 meal_recommendations
        BOOLEAN is_active "NOT NULL, default true"
    }

    %% =====================================================================
    %% RELATIONSHIPS: PART 1 - USER, AUTH & NOTIFICATIONS
    %% =====================================================================
    goal ||--o{ user : "primary_goal_id"
    user ||--|| user_preference : "user_id"
    user ||--o{ refresh_token : "user_id"
    user ||--o{ device_token : "user_id"
    user ||--o{ notification : "user_id"

    %% =====================================================================
    %% RELATIONSHIPS: PART 2 - ONBOARDING & GOALS
    %% =====================================================================
    user ||--o{ user_onboardings : "user_id"
    onboarding_flows ||--o{ onboarding_steps : "flow_id"
    onboarding_flows ||--o{ user_onboardings : "flow_id"
    onboarding_steps ||--o{ user_onboardings : "current_step_id"
    user_onboardings ||--o{ user_onboarding_steps : "onboarding_id"
    onboarding_steps ||--o{ user_onboarding_steps : "step_id"

    %% =====================================================================
    %% RELATIONSHIPS: PART 3 - BODY MEASUREMENTS & PROGRESS PHOTOS
    %% =====================================================================
    user ||--o{ user_measurement : "user_id"
    user ||--|| measurement_goal : "user_id"
    user ||--o{ progress_photo : "user_id"

    %% =====================================================================
    %% RELATIONSHIPS: PART 4 - EXERCISE & REFERENCE LIBRARY
    %% =====================================================================
    exercise ||--o{ exercise_muscle_group : "exercise_id"
    muscle_group ||--o{ exercise_muscle_group : "muscle_group_id"
    exercise ||--o{ exercise_equipment : "exercise_id"
    equipment ||--o{ exercise_equipment : "equipment_id"
    exercise ||--o{ exercise_alternative : "original_exercise_id"
    exercise ||--o{ exercise_alternative : "alternative_exercise_id"

    %% =====================================================================
    %% RELATIONSHIPS: PART 5 - WORKOUT PLANNING & EXECUTION
    %% =====================================================================
    user ||--o{ workout_plan : "user_id"
    goal ||--o{ workout_plan : "goal_id"
    muscle_group ||--o{ workout_plan : "muscle_group_id"
    workout_plan ||--o{ workout_plan_scheduled_date : "plan_id"
    workout_plan ||--o{ workout_session : "plan_id"
    workout_session ||--o{ session_exercise : "session_id"
    exercise ||--o{ session_exercise : "exercise_id"

    user ||--o{ workout_progress : "user_id"
    workout_plan ||--o{ workout_progress : "plan_id"
    workout_session ||--o{ workout_progress : "session_id"
    workout_progress ||--o{ exercise_log : "progress_id"
    exercise ||--o{ exercise_log : "exercise_id"

    user ||--o{ workout_session_log : "user_id"
    workout_plan ||--o{ workout_session_log : "workout_plan_id"
    workout_progress ||--o{ workout_session_log : "workout_progress_id"
    workout_session_log ||--o{ exercise_performance_log : "session_log_id"
    exercise ||--o{ exercise_performance_log : "exercise_id"

    %% =====================================================================
    %% RELATIONSHIPS: PART 6 - NUTRITION PLANNING & MEAL LOGGING
    %% =====================================================================
    user ||--|| nutrition_plan : "user_id"
    goal ||--o{ nutrition_plan : "goal_id"
    nutrition_plan ||--o{ nutrition_day : "nutrition_plan_id"
    nutrition_plan ||--o{ meal_template : "nutrition_plan_id"
    user ||--o{ meal_template : "user_id"
    nutrition_day ||--o{ day_meal : "nutrition_day_id"
    meal_template ||--o{ day_meal : "meal_template_id"

    user ||--o{ plan_meal : "user_id"
    nutrition_plan ||--o{ plan_meal : "nutrition_plan_id"
    meal_template ||--o{ plan_meal : "meal_template_id"

    %% =====================================================================
    %% RELATIONSHIPS: PART 7 - MISSED WORKOUTS, CHEAT MEALS & COMPENSATION
    %% =====================================================================
    user ||--o{ missed_workout : "user_id"
    workout_plan ||--o{ missed_workout : "plan_id"
    workout_session ||--o{ missed_workout : "session_id"

    plan_meal ||--|| cheat_meal_log : "plan_meal_id"
    user ||--o{ cheat_meal_log : "user_id"

    cheat_meal_log ||--o{ compensation_action : "cheat_meal_log_id"
    missed_workout ||--o{ compensation_action : "missed_workout_id"
    compensation_action ||--|| makeup_workout : "compensation_action_id"
    workout_session ||--o{ makeup_workout : "original_session_id"
    workout_session ||--o{ makeup_workout : "replacement_session_id"

    nutrition_plan ||--o{ nutrition_adjustment : "nutrition_plan_id"
    compensation_action ||--o{ nutrition_adjustment : "compensation_action_id"
