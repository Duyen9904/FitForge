-- =====================================================
-- GYM PLAN SEED DATA
-- Comprehensive seed data for gym workout application
-- =====================================================

-- =====================================================
-- 1. MUSCLE GROUPS (Reference data) — Now sourced from external API
-- =====================================================
/* Commented out: muscle groups are now fetched from ExerciseDB v2 API
INSERT IGNORE INTO muscle_group (group_name, category, description, recovery_days_needed) VALUES
-- Chest
('Pectoralis Major', 'CHEST', 'The large fan-shaped muscle that makes up the majority of the chest wall. It is divided into the clavicular and sternal heads.', 2),
('Pectoralis Minor', 'CHEST', 'A thin, triangular muscle beneath the pectoralis major.', 2),
-- Back
('Latissimus Dorsi', 'BACK', 'The largest muscle in the upper body, responsible for extension, adduction, and internal rotation of the shoulder.', 2),
('Trapezius', 'BACK', 'A large superficial back muscle that moves, rotates, and stabilizes the scapula.', 2),
('Rhomboids', 'BACK', 'Located between the shoulder blades, these muscles retract and rotate the scapula.', 2),
('Erector Spinae', 'BACK', 'A group of muscles that run along the spine and are responsible for extending and stabilizing the back.', 3),
-- Shoulders
('Anterior Deltoid', 'SHOULDERS', 'The front section of the deltoid muscle, responsible for shoulder flexion and internal rotation.', 2),
('Lateral Deltoid', 'SHOULDERS', 'The middle section of the deltoid, responsible for shoulder abduction.', 2),
('Posterior Deltoid', 'SHOULDERS', 'The rear section of the deltoid, responsible for shoulder extension and external rotation.', 2),
('Rotator Cuff', 'SHOULDERS', 'A group of four muscles that stabilize the shoulder joint: supraspinatus, infraspinatus, teres minor, and subscapularis.', 2),
-- Arms
('Biceps Brachii', 'ARMS', 'The two-headed muscle on the front of the upper arm responsible for elbow flexion and forearm supination.', 1),
('Triceps Brachii', 'ARMS', 'The three-headed muscle on the back of the upper arm responsible for elbow extension.', 1),
('Forearm Flexors', 'ARMS', 'Muscles on the anterior forearm responsible for wrist and finger flexion.', 1),
('Forearm Extensors', 'ARMS', 'Muscles on the posterior forearm responsible for wrist and finger extension.', 1),
-- Legs
('Quadriceps', 'LEGS', 'A group of four muscles on the front of the thigh responsible for knee extension.', 3),
('Hamstrings', 'LEGS', 'A group of three muscles on the back of the thigh responsible for knee flexion and hip extension.', 3),
('Calves', 'LEGS', 'The gastrocnemius and soleus muscles on the back of the lower leg responsible for plantar flexion.', 2),
('Hip Adductors', 'LEGS', 'Inner thigh muscles responsible for bringing the legs together.', 2),
-- Core
('Rectus Abdominis', 'CORE', 'The "six-pack" muscle running vertically along the front of the abdomen.', 1),
('Obliques', 'CORE', 'Muscles on the sides of the abdomen responsible for trunk rotation and lateral flexion.', 1),
('Transverse Abdominis', 'CORE', 'The deepest abdominal muscle that wraps around the spine for stability.', 1),
-- Glutes
('Gluteus Maximus', 'GLUTES', 'The largest muscle in the body, responsible for hip extension and external rotation.', 2),
('Gluteus Medius', 'GLUTES', 'Located on the outer surface of the pelvis, responsible for hip abduction and stabilization.', 2);
*/

-- =====================================================
-- 2. EQUIPMENT (Reference data) — Now sourced from external API
-- =====================================================
/* Commented out: equipment is now fetched from ExerciseDB v2 API
INSERT IGNORE INTO equipment (equipment_name, equipment_type, description) VALUES
-- Free Weights
('Barbell', 'FREE_WEIGHTS', 'A long metal bar to which weight plates can be attached. Essential for compound movements like squats, deadlifts, and bench press.'),
('Dumbbells', 'FREE_WEIGHTS', 'Handheld weights available in various sizes. Versatile for both strength training and cardio exercises.'),
('EZ Curl Bar', 'FREE_WEIGHTS', 'A curved barbell that reduces strain on the wrists during bicep and tricep exercises.'),
('Kettlebell', 'FREE_WEIGHTS', 'A cast iron weight shaped like a ball with a handle. Used for ballistic exercises and dynamic movements.'),
('Weight Plates', 'FREE_WEIGHTS', 'Circular weights that can be added to barbells for progressive overload.'),
-- Machines
('Cable Machine', 'MACHINE', 'A versatile machine with adjustable pulleys for various resistance exercises.'),
('Leg Press Machine', 'MACHINE', 'A machine for pressing weights away using the legs in a seated or lying position.'),
('Lat Pulldown Machine', 'MACHINE', 'A machine with a wide bar attached to a cable for lat pulldown exercises.'),
('Chest Press Machine', 'MACHINE', 'A machine that simulates the bench press movement with guided resistance.'),
('Leg Curl Machine', 'MACHINE', 'A machine for targeting the hamstrings through leg curling movements.'),
('Leg Extension Machine', 'MACHINE', 'A machine for isolating the quadriceps through leg extension movements.'),
('Hack Squat Machine', 'MACHINE', 'A machine that mimics the squat movement with back support.'),
('Smith Machine', 'MACHINE', 'A barbell fixed within steel rails, allowing only vertical or near-vertical movement.'),
('Pec Deck Machine', 'MACHINE', 'A machine designed for chest fly movements.'),
('Shoulder Press Machine', 'MACHINE', 'A machine for overhead pressing movements targeting the deltoids.'),
-- Benches
('Flat Bench', 'BENCH', 'A horizontal bench for various pressing and rowing exercises.'),
('Incline Bench', 'BENCH', 'An adjustable bench set at an incline for upper chest emphasis.'),
('Decline Bench', 'BENCH', 'A bench set at a decline angle for lower chest emphasis.'),
('Adjustable Bench', 'BENCH', 'A bench with adjustable angles for versatile exercise positions.'),
('Preacher Curl Bench', 'BENCH', 'A bench with an angled pad for isolating the biceps during curls.'),
-- Cardio Equipment
('Treadmill', 'CARDIO', 'A machine for walking, jogging, or running in place.'),
('Stationary Bike', 'CARDIO', 'A bicycle-like device for indoor cycling workouts.'),
('Rowing Machine', 'CARDIO', 'A machine simulating the action of watercraft rowing for full-body cardio.'),
('Elliptical', 'CARDIO', 'A low-impact cardio machine combining stair climbing, walking, and running.'),
('Stair Climber', 'CARDIO', 'A machine simulating climbing stairs for lower body cardio.'),
-- Other
('Pull-up Bar', 'BODYWEIGHT', 'A horizontal bar for performing pull-ups, chin-ups, and hanging exercises.'),
('Dip Station', 'BODYWEIGHT', 'Parallel bars for performing dips targeting chest and triceps.'),
('Resistance Bands', 'ACCESSORIES', 'Elastic bands providing resistance for various exercises. Great for warm-ups and rehabilitation.'),
('Ab Roller', 'ACCESSORIES', 'A wheel with handles for performing ab rollout exercises.'),
('Medicine Ball', 'ACCESSORIES', 'A weighted ball used for functional training and core exercises.'),
('Foam Roller', 'ACCESSORIES', 'A cylindrical foam tool for self-myofascial release and recovery.'),
('Weight Belt', 'ACCESSORIES', 'A belt worn during heavy lifts to support the lower back.'),
('Lifting Straps', 'ACCESSORIES', 'Straps that wrap around the barbell and wrists to improve grip during heavy lifts.');
*/

-- =====================================================
-- 3. GOALS (Reference data)
-- =====================================================
INSERT IGNORE INTO goal (goal_name, description, recommended_rep_range, recommended_rest_time, recommended_frequency, target_calorie_adjustment) VALUES
('Build Muscle', 'Hypertrophy-focused training to increase muscle size and definition. Emphasizes progressive overload and time under tension.', '8-12 reps', '60-90 seconds', '4-5 days/week', 300),
('Lose Fat', 'Fat loss program combining resistance training with higher volume and cardio. Maintains muscle while creating caloric deficit.', '12-15 reps', '30-45 seconds', '5-6 days/week', -500),
('Increase Strength', 'Strength training program focused on compound movements and progressive overload. Emphasizes lower reps with heavier weights.', '3-6 reps', '2-3 minutes', '3-4 days/week', 200),
('Build Endurance', 'Muscular endurance training with higher repetitions and shorter rest periods. Improves stamina and work capacity.', '15-20 reps', '30 seconds', '4-5 days/week', 0),
('General Fitness', 'Balanced approach to overall fitness combining strength, cardio, and flexibility. Perfect for beginners or maintenance.', '10-15 reps', '60 seconds', '3-4 days/week', 0),
('Powerlifting', 'Competition-focused training for squat, bench press, and deadlift. Periodized program for maximum strength development.', '1-5 reps', '3-5 minutes', '4 days/week', 500),
('Athletic Performance', 'Sport-specific training combining strength, power, speed, and agility. Includes plyometrics and functional movements.', '6-8 reps', '90-120 seconds', '5 days/week', 250);

-- =====================================================
-- 4. ACHIEVEMENTS (Gamification)
-- =====================================================
INSERT IGNORE INTO achievement (achievement_name, description, badge_icon_url, criteria, points, category) VALUES
-- Consistency Achievements
('First Workout', 'Complete your first workout session', '/badges/first-workout.png', 'Complete 1 workout', 10, 'CONSISTENCY'),
('Week Warrior', 'Complete 7 workouts in a week', '/badges/week-warrior.png', 'Complete 7 workouts within 7 days', 50, 'CONSISTENCY'),
('Monthly Dedication', 'Complete 20 workouts in a month', '/badges/monthly-dedication.png', 'Complete 20 workouts within 30 days', 100, 'CONSISTENCY'),
('Iron Regular', 'Work out for 30 consecutive days', '/badges/iron-regular.png', 'Log workouts for 30 consecutive days', 500, 'CONSISTENCY'),
('Gym Rat', 'Complete 100 total workouts', '/badges/gym-rat.png', 'Complete 100 total workout sessions', 200, 'CONSISTENCY'),
('Fitness Lifestyle', 'Work out for 365 consecutive days', '/badges/fitness-lifestyle.png', 'Log workouts for 365 consecutive days', 2000, 'CONSISTENCY'),
-- Strength Achievements
('First PR', 'Set your first personal record', '/badges/first-pr.png', 'Lift more weight than your previous best on any exercise', 25, 'STRENGTH'),
('Plate Club', 'Bench press 135 lbs (1 plate per side)', '/badges/plate-club.png', 'Complete bench press with 135 lbs', 100, 'STRENGTH'),
('Two Plate Club', 'Bench press 225 lbs (2 plates per side)', '/badges/two-plate-club.png', 'Complete bench press with 225 lbs', 250, 'STRENGTH'),
('Squat Master', 'Squat your body weight', '/badges/squat-master.png', 'Complete a squat with weight equal to body weight', 150, 'STRENGTH'),
('Deadlift King', 'Deadlift 1.5x your body weight', '/badges/deadlift-king.png', 'Complete a deadlift with 1.5x body weight', 200, 'STRENGTH'),
('1000 lb Club', 'Combined total of 1000 lbs for squat, bench, and deadlift', '/badges/1000-club.png', 'SQ + BP + DL >= 1000 lbs', 1000, 'STRENGTH'),
-- Volume Achievements
('Rep Champion', 'Complete 1000 total reps', '/badges/rep-champion.png', 'Log 1000 total repetitions', 75, 'VOLUME'),
('Set Setter', 'Complete 500 total sets', '/badges/set-setter.png', 'Log 500 total sets', 100, 'VOLUME'),
('Heavy Lifter', 'Lift 100,000 lbs total volume', '/badges/heavy-lifter.png', 'Total volume lifted >= 100,000 lbs', 300, 'VOLUME'),
-- Exploration Achievements
('Exercise Explorer', 'Try 20 different exercises', '/badges/exercise-explorer.png', 'Log 20 unique exercises', 50, 'EXPLORATION'),
('Full Body Focus', 'Train all major muscle groups in one week', '/badges/full-body.png', 'Log exercises for chest, back, shoulders, arms, legs, and core within 7 days', 75, 'EXPLORATION'),
('Equipment Master', 'Use 10 different types of equipment', '/badges/equipment-master.png', 'Log exercises using 10 different equipment types', 60, 'EXPLORATION'),
-- Nutrition Achievements
('Nutrition Tracker', 'Log meals for 7 consecutive days', '/badges/nutrition-tracker.png', 'Log nutrition for 7 days straight', 40, 'NUTRITION'),
('Protein Pro', 'Hit your protein goal for 30 days', '/badges/protein-pro.png', 'Meet daily protein target for 30 days', 150, 'NUTRITION'),
-- Body Composition
('First Weigh-In', 'Log your first body measurement', '/badges/first-weighin.png', 'Log one body measurement', 10, 'BODY'),
('Transformation', 'Lose or gain 10 lbs towards your goal', '/badges/transformation.png', 'Change body weight by 10 lbs in goal direction', 250, 'BODY');

-- =====================================================
-- 5. EXERCISES — Now sourced from external API
-- =====================================================
/* Commented out: exercises are now fetched from ExerciseDB v2 API
INSERT IGNORE INTO exercise (exercise_id, exercise_name, description, difficulty_level, exercise_type, instructions, video_url, image_url, calories_burned_per_min, requires_spotter, equipment_category) VALUES
-- CHEST EXERCISES
('barbell-bench-press', 'Barbell Bench Press', 'The king of chest exercises. A compound movement that targets the pectoralis major while also engaging the anterior deltoids and triceps.', 'INTERMEDIATE', 'COMPOUND', '1. Lie flat on a bench with feet flat on the floor. 2. Grip the barbell slightly wider than shoulder-width. 3. Unrack the bar and lower it to your mid-chest. 4. Press the bar back up to full arm extension. 5. Keep your core tight and maintain a slight arch in your lower back.', '/videos/bench-press.mp4', '/images/bench-press.jpg', 8, true, 'FREE_WEIGHTS'),
('incline-dumbbell-press', 'Incline Dumbbell Press', 'An upper chest-focused pressing movement that also engages the front deltoids. Great for building the clavicular head of the pecs.', 'INTERMEDIATE', 'COMPOUND', '1. Set bench to 30-45 degree incline. 2. Hold dumbbells at shoulder level with palms facing forward. 3. Press dumbbells up and together. 4. Lower slowly to starting position. 5. Keep core engaged throughout.', '/videos/incline-db-press.mp4', '/images/incline-db-press.jpg', 7, false, 'FREE_WEIGHTS'),
('dumbbell-fly', 'Dumbbell Fly', 'An isolation exercise for the chest that emphasizes the stretch and contraction of the pectoralis major.', 'BEGINNER', 'ISOLATION', '1. Lie on a flat bench holding dumbbells above your chest. 2. With a slight bend in elbows, lower arms out to sides. 3. Feel a stretch in your chest at the bottom. 4. Squeeze chest muscles to bring arms back together. 5. Maintain the slight elbow bend throughout.', '/videos/db-fly.mp4', '/images/db-fly.jpg', 5, false, 'FREE_WEIGHTS'),
('cable-crossover', 'Cable Crossover', 'A cable exercise providing constant tension throughout the movement for excellent chest isolation.', 'BEGINNER', 'ISOLATION', '1. Set cables at upper pulley position. 2. Stand in the middle with one foot forward. 3. With slight elbow bend, bring hands together in front. 4. Squeeze chest at the contracted position. 5. Slowly return to starting position.', '/videos/cable-crossover.mp4', '/images/cable-crossover.jpg', 6, false, 'MACHINE'),
('push-ups', 'Push-Ups', 'A fundamental bodyweight exercise for building chest, shoulder, and tricep strength.', 'BEGINNER', 'COMPOUND', '1. Place hands slightly wider than shoulder-width on the floor. 2. Keep body in a straight line from head to heels. 3. Lower chest to the floor by bending elbows. 4. Push back up to starting position. 5. Keep core tight throughout the movement.', '/videos/pushups.mp4', '/images/pushups.jpg', 8, false, 'BODYWEIGHT'),
('decline-bench-press', 'Decline Bench Press', 'A pressing variation that emphasizes the lower portion of the pectoralis major.', 'INTERMEDIATE', 'COMPOUND', '1. Secure legs at the end of a decline bench. 2. Grip barbell slightly wider than shoulder-width. 3. Lower bar to lower chest. 4. Press bar back up to full extension. 5. Use a spotter for safety.', '/videos/decline-press.mp4', '/images/decline-press.jpg', 8, true, 'FREE_WEIGHTS'),
('dips-chest', 'Dips (Chest)', 'A compound movement targeting the lower chest, triceps, and shoulders.', 'INTERMEDIATE', 'COMPOUND', '1. Grip dip bars and lift yourself up. 2. Lean forward slightly to target chest. 3. Lower body until upper arms are parallel to floor. 4. Press back up to starting position. 5. Keep elbows slightly flared.', '/videos/chest-dips.mp4', '/images/chest-dips.jpg', 9, false, 'BODYWEIGHT'),

-- BACK EXERCISES
('barbell-deadlift', 'Barbell Deadlift', 'The ultimate compound movement for overall back development, posterior chain strength, and total body power.', 'ADVANCED', 'COMPOUND', '1. Stand with feet hip-width apart, bar over mid-foot. 2. Hinge at hips and grip bar just outside legs. 3. Keep back flat, chest up, and core braced. 4. Drive through heels and extend hips and knees. 5. Stand tall, then lower with control.', '/videos/deadlift.mp4', '/images/deadlift.jpg', 10, false, 'FREE_WEIGHTS'),
('pull-ups', 'Pull-Ups', 'A fundamental bodyweight exercise for developing a wide, strong back.', 'INTERMEDIATE', 'COMPOUND', '1. Hang from bar with overhand grip wider than shoulders. 2. Pull yourself up until chin clears the bar. 3. Lower with control to full arm extension. 4. Keep core tight and avoid swinging. 5. Focus on pulling with your back, not arms.', '/videos/pullups.mp4', '/images/pullups.jpg', 9, false, 'BODYWEIGHT'),
('barbell-row', 'Barbell Row', 'A powerful compound movement for building overall back thickness and strength.', 'INTERMEDIATE', 'COMPOUND', '1. Hinge forward at hips, keeping back flat. 2. Grip barbell with overhand or underhand grip. 3. Pull bar to lower chest/upper abs. 4. Squeeze shoulder blades together at top. 5. Lower with control and repeat.', '/videos/barbell-row.mp4', '/images/barbell-row.jpg', 7, false, 'FREE_WEIGHTS'),
('lat-pulldown', 'Lat Pulldown', 'A machine exercise that mimics the pull-up movement, excellent for developing the lats.', 'BEGINNER', 'COMPOUND', '1. Sit at lat pulldown machine, thighs under pads. 2. Grip bar wider than shoulder-width. 3. Pull bar down to upper chest. 4. Squeeze lats at the bottom of the movement. 5. Control the weight back to start.', '/videos/lat-pulldown.mp4', '/images/lat-pulldown.jpg', 6, false, 'MACHINE'),
('seated-cable-row', 'Seated Cable Row', 'A machine exercise for mid-back thickness and development.', 'BEGINNER', 'COMPOUND', '1. Sit at cable row station with feet on platform. 2. Grip handle with arms extended. 3. Pull handle to lower chest. 4. Squeeze shoulder blades together. 5. Extend arms with control.', '/videos/seated-row.mp4', '/images/seated-row.jpg', 6, false, 'MACHINE'),
('dumbbell-row', 'Dumbbell Row', 'A unilateral back exercise that allows for full range of motion and muscle balance.', 'BEGINNER', 'COMPOUND', '1. Place one knee and hand on bench. 2. Hold dumbbell in opposite hand. 3. Pull dumbbell to hip, keeping elbow close. 4. Squeeze back muscles at top. 5. Lower with control and repeat.', '/videos/db-row.mp4', '/images/db-row.jpg', 6, false, 'FREE_WEIGHTS'),
('t-bar-row', 'T-Bar Row', 'A compound rowing variation that allows for heavy loading and back development.', 'INTERMEDIATE', 'COMPOUND', '1. Straddle T-bar with feet hip-width apart. 2. Hinge forward and grip handles. 3. Pull weight to chest, keeping back flat. 4. Squeeze shoulder blades at top. 5. Lower with control.', '/videos/tbar-row.mp4', '/images/tbar-row.jpg', 7, false, 'FREE_WEIGHTS'),
('face-pulls', 'Face Pulls', 'An exercise targeting the rear deltoids and upper back for posture and shoulder health.', 'BEGINNER', 'ISOLATION', '1. Set cable to face height with rope attachment. 2. Grip rope with palms facing down. 3. Pull rope towards face, separating hands. 4. Squeeze rear delts at the end. 5. Return with control.', '/videos/face-pulls.mp4', '/images/face-pulls.jpg', 4, false, 'MACHINE'),

-- SHOULDER EXERCISES
('overhead-press', 'Overhead Press', 'The primary compound movement for shoulder development and pressing strength.', 'INTERMEDIATE', 'COMPOUND', '1. Start with bar at upper chest, feet shoulder-width. 2. Grip bar just outside shoulder-width. 3. Press bar straight up overhead. 4. Lock out arms at the top. 5. Lower with control to starting position.', '/videos/ohp.mp4', '/images/ohp.jpg', 7, true, 'FREE_WEIGHTS'),
('dumbbell-shoulder-press', 'Dumbbell Shoulder Press', 'A versatile pressing movement that allows for natural arm path and unilateral work.', 'INTERMEDIATE', 'COMPOUND', '1. Sit on bench with back support. 2. Hold dumbbells at shoulder level. 3. Press dumbbells straight up. 4. Touch weights together at top. 5. Lower with control.', '/videos/db-shoulder-press.mp4', '/images/db-shoulder-press.jpg', 7, false, 'FREE_WEIGHTS'),
('lateral-raises', 'Lateral Raises', 'An isolation exercise for developing the lateral deltoid for wider shoulders.', 'BEGINNER', 'ISOLATION', '1. Stand holding dumbbells at sides. 2. With slight elbow bend, raise arms to sides. 3. Lift until arms are parallel to floor. 4. Lower slowly with control. 5. Avoid using momentum.', '/videos/lateral-raises.mp4', '/images/lateral-raises.jpg', 4, false, 'FREE_WEIGHTS'),
('front-raises', 'Front Raises', 'An isolation movement targeting the anterior deltoid.', 'BEGINNER', 'ISOLATION', '1. Stand holding dumbbells in front of thighs. 2. With slight elbow bend, raise one or both arms forward. 3. Lift to shoulder height. 4. Lower with control. 5. Keep core engaged.', '/videos/front-raises.mp4', '/images/front-raises.jpg', 4, false, 'FREE_WEIGHTS'),
('reverse-fly', 'Reverse Fly', 'An isolation exercise for the posterior deltoid and upper back.', 'BEGINNER', 'ISOLATION', '1. Bend forward at hips, dumbbells hanging. 2. With slight elbow bend, raise arms to sides. 3. Squeeze rear delts at top. 4. Lower with control. 5. Keep back flat throughout.', '/videos/reverse-fly.mp4', '/images/reverse-fly.jpg', 4, false, 'FREE_WEIGHTS'),
('arnold-press', 'Arnold Press', 'A dumbbell pressing variation that works all three heads of the deltoid through rotation.', 'INTERMEDIATE', 'COMPOUND', '1. Start with dumbbells at shoulder level, palms facing you. 2. As you press up, rotate palms to face forward. 3. Lock out at the top. 4. Reverse the movement on the way down. 5. Maintain controlled tempo.', '/videos/arnold-press.mp4', '/images/arnold-press.jpg', 6, false, 'FREE_WEIGHTS'),
('upright-row', 'Upright Row', 'A compound movement for the deltoids and trapezius.', 'INTERMEDIATE', 'COMPOUND', '1. Hold barbell with narrow grip in front of thighs. 2. Pull bar up close to body. 3. Lead with elbows, keep them high. 4. Lift to chin level. 5. Lower with control.', '/videos/upright-row.mp4', '/images/upright-row.jpg', 5, false, 'FREE_WEIGHTS'),
('shrugs', 'Shrugs', 'An isolation exercise for the upper trapezius muscles.', 'BEGINNER', 'ISOLATION', '1. Hold heavy dumbbells or barbell at sides. 2. Shrug shoulders straight up towards ears. 3. Hold briefly at the top. 4. Lower slowly with control. 5. Avoid rolling shoulders.', '/videos/shrugs.mp4', '/images/shrugs.jpg', 4, false, 'FREE_WEIGHTS'),

-- ARM EXERCISES (Biceps)
('barbell-curl', 'Barbell Curl', 'The classic bicep exercise for building overall arm mass.', 'BEGINNER', 'ISOLATION', '1. Stand holding barbell with underhand grip. 2. Keep elbows at sides and core tight. 3. Curl bar up to shoulder level. 4. Squeeze biceps at top. 5. Lower with control.', '/videos/barbell-curl.mp4', '/images/barbell-curl.jpg', 5, false, 'FREE_WEIGHTS'),
('dumbbell-curl', 'Dumbbell Curl', 'A versatile bicep exercise allowing for various grip positions and unilateral work.', 'BEGINNER', 'ISOLATION', '1. Stand holding dumbbells at sides. 2. Curl weights up, supinating wrists. 3. Squeeze biceps at top. 4. Lower with control. 5. Alternate arms or curl simultaneously.', '/videos/db-curl.mp4', '/images/db-curl.jpg', 5, false, 'FREE_WEIGHTS'),
('hammer-curl', 'Hammer Curl', 'A curl variation that targets the brachialis and forearms along with the biceps.', 'BEGINNER', 'ISOLATION', '1. Hold dumbbells with neutral grip (palms facing each other). 2. Curl weights up keeping neutral grip. 3. Squeeze at top. 4. Lower with control. 5. Keep elbows stationary.', '/videos/hammer-curl.mp4', '/images/hammer-curl.jpg', 5, false, 'FREE_WEIGHTS'),
('preacher-curl', 'Preacher Curl', 'An isolation exercise that eliminates momentum for strict bicep work.', 'INTERMEDIATE', 'ISOLATION', '1. Sit at preacher bench with arms on pad. 2. Hold barbell or dumbbells with underhand grip. 3. Curl weight up. 4. Squeeze biceps at top. 5. Lower slowly, feeling the stretch.', '/videos/preacher-curl.mp4', '/images/preacher-curl.jpg', 4, false, 'FREE_WEIGHTS'),
('concentration-curl', 'Concentration Curl', 'A strict isolation exercise for peak bicep contraction.', 'BEGINNER', 'ISOLATION', '1. Sit on bench, lean forward. 2. Brace elbow against inner thigh. 3. Curl dumbbell up to shoulder. 4. Squeeze hard at top. 5. Lower with control.', '/videos/concentration-curl.mp4', '/images/concentration-curl.jpg', 4, false, 'FREE_WEIGHTS'),
('cable-curl', 'Cable Curl', 'A bicep exercise providing constant tension throughout the movement.', 'BEGINNER', 'ISOLATION', '1. Stand facing cable machine with bar attachment. 2. Grip bar with underhand grip. 3. Curl bar up to shoulders. 4. Squeeze biceps. 5. Lower with control.', '/videos/cable-curl.mp4', '/images/cable-curl.jpg', 4, false, 'MACHINE'),

-- ARM EXERCISES (Triceps)
('tricep-pushdown', 'Tricep Pushdown', 'A cable exercise for isolating the triceps.', 'BEGINNER', 'ISOLATION', '1. Stand at cable machine with rope or bar. 2. Keep elbows at sides. 3. Push weight down until arms are straight. 4. Squeeze triceps at bottom. 5. Return with control.', '/videos/tricep-pushdown.mp4', '/images/tricep-pushdown.jpg', 4, false, 'MACHINE'),
('skull-crushers', 'Skull Crushers', 'A lying tricep extension that targets all three heads of the tricep.', 'INTERMEDIATE', 'ISOLATION', '1. Lie on bench holding EZ bar overhead. 2. Lower bar by bending elbows only. 3. Bring bar towards forehead or behind head. 4. Extend arms back up. 5. Keep upper arms stationary.', '/videos/skull-crushers.mp4', '/images/skull-crushers.jpg', 5, false, 'FREE_WEIGHTS'),
('close-grip-bench-press', 'Close-Grip Bench Press', 'A compound pressing movement emphasizing the triceps.', 'INTERMEDIATE', 'COMPOUND', '1. Lie on bench, grip bar with hands shoulder-width apart. 2. Lower bar to lower chest. 3. Keep elbows close to body. 4. Press bar back up. 5. Squeeze triceps at top.', '/videos/close-grip-bp.mp4', '/images/close-grip-bp.jpg', 7, true, 'FREE_WEIGHTS'),
('overhead-tricep-extension', 'Overhead Tricep Extension', 'A tricep exercise emphasizing the long head of the tricep.', 'BEGINNER', 'ISOLATION', '1. Hold dumbbell overhead with both hands. 2. Lower weight behind head by bending elbows. 3. Keep upper arms close to ears. 4. Extend arms back up. 5. Squeeze triceps at top.', '/videos/oh-tricep-ext.mp4', '/images/oh-tricep-ext.jpg', 4, false, 'FREE_WEIGHTS'),
('tricep-dips', 'Tricep Dips', 'A bodyweight exercise for building tricep and chest strength.', 'INTERMEDIATE', 'COMPOUND', '1. Grip parallel bars and lift yourself up. 2. Keep body upright to target triceps. 3. Lower until upper arms are parallel to floor. 4. Press back up to full extension. 5. Keep elbows close to body.', '/videos/tricep-dips.mp4', '/images/tricep-dips.jpg', 8, false, 'BODYWEIGHT'),
('tricep-kickbacks', 'Tricep Kickbacks', 'An isolation exercise for the tricep with emphasis on contraction.', 'BEGINNER', 'ISOLATION', '1. Hinge forward, arm bent at 90 degrees. 2. Keep upper arm parallel to floor. 3. Extend forearm back until arm is straight. 4. Squeeze tricep at full extension. 5. Lower with control.', '/videos/tricep-kickbacks.mp4', '/images/tricep-kickbacks.jpg', 3, false, 'FREE_WEIGHTS'),

-- LEG EXERCISES
('barbell-squat', 'Barbell Squat', 'The king of leg exercises. A compound movement that targets the entire lower body.', 'INTERMEDIATE', 'COMPOUND', '1. Set bar on upper back, feet shoulder-width. 2. Brace core and keep chest up. 3. Sit back and down until thighs are parallel. 4. Drive through heels to stand. 5. Keep knees tracking over toes.', '/videos/squat.mp4', '/images/squat.jpg', 10, true, 'FREE_WEIGHTS'),
('leg-press', 'Leg Press', 'A machine exercise for building leg size and strength with reduced spinal load.', 'BEGINNER', 'COMPOUND', '1. Sit in leg press with back flat against pad. 2. Place feet shoulder-width on platform. 3. Lower platform by bending knees. 4. Push through heels to extend legs. 5. Dont lock out knees at top.', '/videos/leg-press.mp4', '/images/leg-press.jpg', 8, false, 'MACHINE'),
('romanian-deadlift', 'Romanian Deadlift', 'A hip hinge movement targeting the hamstrings and glutes.', 'INTERMEDIATE', 'COMPOUND', '1. Hold barbell in front of thighs. 2. Push hips back, lowering bar along legs. 3. Keep slight knee bend. 4. Feel stretch in hamstrings. 5. Drive hips forward to stand.', '/videos/rdl.mp4', '/images/rdl.jpg', 8, false, 'FREE_WEIGHTS'),
('leg-curl', 'Leg Curl', 'An isolation exercise for the hamstrings.', 'BEGINNER', 'ISOLATION', '1. Lie face down on leg curl machine. 2. Position pad just above heels. 3. Curl weight up by bending knees. 4. Squeeze hamstrings at top. 5. Lower with control.', '/videos/leg-curl.mp4', '/images/leg-curl.jpg', 4, false, 'MACHINE'),
('leg-extension', 'Leg Extension', 'An isolation exercise for the quadriceps.', 'BEGINNER', 'ISOLATION', '1. Sit on leg extension machine. 2. Position pad on lower shins. 3. Extend legs to straighten. 4. Squeeze quads at top. 5. Lower with control.', '/videos/leg-extension.mp4', '/images/leg-extension.jpg', 4, false, 'MACHINE'),
('lunges', 'Lunges', 'A unilateral leg exercise for building strength and balance.', 'BEGINNER', 'COMPOUND', '1. Stand with feet together. 2. Step forward into a lunge. 3. Lower until both knees are at 90 degrees. 4. Push through front foot to stand. 5. Alternate legs.', '/videos/lunges.mp4', '/images/lunges.jpg', 7, false, 'BODYWEIGHT'),
('bulgarian-split-squat', 'Bulgarian Split Squat', 'A challenging unilateral exercise for leg development and stability.', 'INTERMEDIATE', 'COMPOUND', '1. Stand in front of bench, place rear foot on it. 2. Lower until front thigh is parallel to floor. 3. Keep torso upright. 4. Drive through front heel to stand. 5. Keep knee tracking over toe.', '/videos/bulgarian-split.mp4', '/images/bulgarian-split.jpg', 8, false, 'BODYWEIGHT'),
('calf-raises', 'Calf Raises', 'An isolation exercise for the calf muscles.', 'BEGINNER', 'ISOLATION', '1. Stand on edge of step with heels hanging off. 2. Rise up on toes as high as possible. 3. Hold briefly at top. 4. Lower heels below step level. 5. Feel full stretch at bottom.', '/videos/calf-raises.mp4', '/images/calf-raises.jpg', 4, false, 'BODYWEIGHT'),
('hack-squat', 'Hack Squat', 'A machine squat variation for targeting the quadriceps with back support.', 'INTERMEDIATE', 'COMPOUND', '1. Position shoulders under pads of hack squat. 2. Place feet shoulder-width on platform. 3. Lower weight by bending knees. 4. Go until thighs are parallel. 5. Press back up through heels.', '/videos/hack-squat.mp4', '/images/hack-squat.jpg', 8, false, 'MACHINE'),
('hip-thrust', 'Hip Thrust', 'An exercise specifically targeting the glutes for building strength and size.', 'INTERMEDIATE', 'COMPOUND', '1. Sit with upper back against bench, barbell over hips. 2. Plant feet flat on floor. 3. Drive hips up by squeezing glutes. 4. Hold briefly at top. 5. Lower with control.', '/videos/hip-thrust.mp4', '/images/hip-thrust.jpg', 7, false, 'FREE_WEIGHTS'),

-- CORE EXERCISES
('plank', 'Plank', 'An isometric core exercise for building overall core stability and endurance.', 'BEGINNER', 'ISOLATION', '1. Position forearms on floor, elbows under shoulders. 2. Extend legs back, toes on floor. 3. Keep body in straight line. 4. Engage core and hold position. 5. Breathe normally throughout.', '/videos/plank.mp4', '/images/plank.jpg', 4, false, 'BODYWEIGHT'),
('crunches', 'Crunches', 'A basic abdominal exercise for targeting the rectus abdominis.', 'BEGINNER', 'ISOLATION', '1. Lie on back, knees bent, feet flat. 2. Place hands behind head or across chest. 3. Curl shoulders off floor. 4. Squeeze abs at top. 5. Lower with control.', '/videos/crunches.mp4', '/images/crunches.jpg', 5, false, 'BODYWEIGHT'),
('russian-twist', 'Russian Twist', 'A rotational core exercise targeting the obliques.', 'BEGINNER', 'ISOLATION', '1. Sit with knees bent, feet off floor. 2. Lean back slightly, holding weight at chest. 3. Rotate torso to one side. 4. Touch weight to floor. 5. Rotate to other side.', '/videos/russian-twist.mp4', '/images/russian-twist.jpg', 5, false, 'BODYWEIGHT'),
('hanging-leg-raise', 'Hanging Leg Raise', 'An advanced core exercise targeting the lower abs.', 'ADVANCED', 'ISOLATION', '1. Hang from pull-up bar with arms straight. 2. Keep legs straight or slightly bent. 3. Raise legs to parallel or higher. 4. Lower with control. 5. Avoid swinging.', '/videos/hanging-leg-raise.mp4', '/images/hanging-leg-raise.jpg', 6, false, 'BODYWEIGHT'),
('cable-woodchop', 'Cable Woodchop', 'A rotational core exercise that mimics functional movements.', 'INTERMEDIATE', 'COMPOUND', '1. Stand sideways to cable machine. 2. Set cable high, grip handle with both hands. 3. Pull diagonally across body. 4. Rotate through core. 5. Control return movement.', '/videos/cable-woodchop.mp4', '/images/cable-woodchop.jpg', 5, false, 'MACHINE'),
('ab-rollout', 'Ab Rollout', 'An advanced core exercise for building anti-extension strength.', 'ADVANCED', 'ISOLATION', '1. Kneel on floor holding ab roller. 2. Roll forward, extending body. 3. Go as far as you can control. 4. Contract abs to roll back. 5. Keep hips from sagging.', '/videos/ab-rollout.mp4', '/images/ab-rollout.jpg', 6, false, 'ACCESSORIES'),
('dead-bug', 'Dead Bug', 'A core stability exercise excellent for beginners and rehabilitation.', 'BEGINNER', 'ISOLATION', '1. Lie on back, arms extended to ceiling. 2. Lift legs with knees at 90 degrees. 3. Lower opposite arm and leg. 4. Keep lower back pressed to floor. 5. Return and alternate sides.', '/videos/dead-bug.mp4', '/images/dead-bug.jpg', 3, false, 'BODYWEIGHT'),
('mountain-climbers', 'Mountain Climbers', 'A dynamic core exercise that also elevates heart rate.', 'BEGINNER', 'COMPOUND', '1. Start in push-up position. 2. Drive one knee towards chest. 3. Quickly switch legs. 4. Continue alternating at rapid pace. 5. Keep hips level throughout.', '/videos/mountain-climbers.mp4', '/images/mountain-climbers.jpg', 10, false, 'BODYWEIGHT');
*/

-- =====================================================
-- 6. EXERCISE-MUSCLE GROUP RELATIONSHIPS — Now auto-created by API
-- =====================================================
/* Commented out: relationships are now created when exercises are fetched from API
INSERT IGNORE INTO exercise_muscle_group (exercise_id, muscle_group_id, intensity_level, is_primary) VALUES
-- Barbell Bench Press
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Bench Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Pectoralis Major'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Bench Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Anterior Deltoid'), 'MEDIUM', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Bench Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Triceps Brachii'), 'MEDIUM', false),
-- Incline Dumbbell Press
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Incline Dumbbell Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Pectoralis Major'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Incline Dumbbell Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Anterior Deltoid'), 'MEDIUM', false),
-- Dumbbell Fly
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Fly'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Pectoralis Major'), 'HIGH', true),
-- Push-Ups
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Push-Ups'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Pectoralis Major'), 'MEDIUM', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Push-Ups'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Anterior Deltoid'), 'LOW', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Push-Ups'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Triceps Brachii'), 'MEDIUM', false),
-- Back Exercises
-- Barbell Deadlift
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Erector Spinae'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Gluteus Maximus'), 'HIGH', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Hamstrings'), 'HIGH', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Quadriceps'), 'MEDIUM', false),
-- Pull-Ups
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Pull-Ups'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Latissimus Dorsi'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Pull-Ups'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Biceps Brachii'), 'MEDIUM', false),
-- Lat Pulldown
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Lat Pulldown'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Latissimus Dorsi'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Lat Pulldown'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Biceps Brachii'), 'LOW', false),
-- Barbell Row
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Row'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Latissimus Dorsi'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Row'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Rhomboids'), 'MEDIUM', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Row'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Trapezius'), 'MEDIUM', false),
-- Shoulder Exercises
-- Overhead Press
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Overhead Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Anterior Deltoid'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Overhead Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Lateral Deltoid'), 'MEDIUM', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Overhead Press'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Triceps Brachii'), 'MEDIUM', false),
-- Lateral Raises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Lateral Raises'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Lateral Deltoid'), 'HIGH', true),
-- Face Pulls
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Face Pulls'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Posterior Deltoid'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Face Pulls'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Rhomboids'), 'MEDIUM', false),
-- Arm Exercises
-- Barbell Curl
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Curl'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Biceps Brachii'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Curl'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Forearm Flexors'), 'LOW', false),
-- Tricep Pushdown
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Tricep Pushdown'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Triceps Brachii'), 'HIGH', true),
-- Skull Crushers
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Skull Crushers'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Triceps Brachii'), 'HIGH', true),
-- Leg Exercises
-- Barbell Squat
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Squat'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Quadriceps'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Squat'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Gluteus Maximus'), 'HIGH', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Squat'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Hamstrings'), 'MEDIUM', false),
-- Romanian Deadlift
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Romanian Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Hamstrings'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Romanian Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Gluteus Maximus'), 'HIGH', false),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Romanian Deadlift'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Erector Spinae'), 'MEDIUM', false),
-- Hip Thrust
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hip Thrust'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Gluteus Maximus'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hip Thrust'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Hamstrings'), 'MEDIUM', false),
-- Core Exercises
-- Plank
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Plank'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Rectus Abdominis'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Plank'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Transverse Abdominis'), 'HIGH', false),
-- Russian Twist
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Russian Twist'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Obliques'), 'HIGH', true),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Russian Twist'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Rectus Abdominis'), 'MEDIUM', false),
-- Hanging Leg Raise
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hanging Leg Raise'), (SELECT muscle_group_id FROM muscle_group WHERE group_name = 'Rectus Abdominis'), 'HIGH', true);
*/

-- =====================================================
-- 7. EXERCISE-EQUIPMENT RELATIONSHIPS — Now auto-created by API
-- =====================================================
/* Commented out: relationships are now created when exercises are fetched from API
INSERT IGNORE INTO exercise_equipment (exercise_id, equipment_id, is_required, usage_notes) VALUES
-- Chest Exercises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Bench Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, 'Standard Olympic barbell recommended'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Bench Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Flat Bench'), true, 'Use a sturdy bench with safety catches'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Bench Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Weight Plates'), true, 'Adjust weight based on experience level'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Incline Dumbbell Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Incline Dumbbell Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Incline Bench'), true, 'Set to 30-45 degree angle'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Fly'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, 'Use lighter weight than pressing exercises'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Fly'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Flat Bench'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Cable Crossover'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Cable Machine'), true, 'Set pulleys to high position'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dips (Chest)'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dip Station'), true, NULL),
-- Back Exercises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Weight Plates'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Weight Belt'), false, 'Recommended for heavy lifts'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Deadlift'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Lifting Straps'), false, 'Optional for grip support'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Pull-Ups'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Pull-up Bar'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Lat Pulldown'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Lat Pulldown Machine'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Row'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Seated Cable Row'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Cable Machine'), true, 'Use V-handle or straight bar attachment'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Row'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Row'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Flat Bench'), true, 'For support'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Face Pulls'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Cable Machine'), true, 'Use rope attachment'),
-- Shoulder Exercises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Overhead Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Shoulder Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Shoulder Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Adjustable Bench'), true, 'Set to 90 degrees'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Lateral Raises'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, 'Use light to moderate weight'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Front Raises'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Reverse Fly'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Shrugs'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, 'Can also use barbell'),
-- Arm Exercises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, 'Can use EZ bar'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Dumbbell Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hammer Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Preacher Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Preacher Curl Bench'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Preacher Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'EZ Curl Bar'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Cable Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Cable Machine'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Tricep Pushdown'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Cable Machine'), true, 'Use rope or straight bar'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Skull Crushers'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'EZ Curl Bar'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Skull Crushers'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Flat Bench'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Close-Grip Bench Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Close-Grip Bench Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Flat Bench'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Overhead Tricep Extension'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dumbbells'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Tricep Dips'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Dip Station'), true, NULL),
-- Leg Exercises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Squat'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Squat'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Weight Plates'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Barbell Squat'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Weight Belt'), false, 'Recommended for heavy squats'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Leg Press'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Leg Press Machine'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Romanian Deadlift'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Leg Curl'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Leg Curl Machine'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Leg Extension'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Leg Extension Machine'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hack Squat'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Hack Squat Machine'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hip Thrust'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Barbell'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hip Thrust'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Flat Bench'), true, 'For back support'),
-- Core Exercises
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Russian Twist'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Medicine Ball'), false, 'Can use dumbbell or weight plate'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Hanging Leg Raise'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Pull-up Bar'), true, NULL),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Cable Woodchop'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Cable Machine'), true, 'Use single handle attachment'),
((SELECT exercise_id FROM exercise WHERE exercise_name = 'Ab Rollout'), (SELECT equipment_id FROM equipment WHERE equipment_name = 'Ab Roller'), true, NULL);
*/

-- =====================================================
-- 8. ONBOARDING (Steps and options)
-- =====================================================
INSERT IGNORE INTO onboarding_step (step_key, title, subtitle, help_text, step_type, input_type, display_order, is_required, is_active, icon_url) VALUES
('gender', 'Gender', 'What is your gender?', 'We use this to personalize your experience.', 'GENDER', 'SINGLE_CHOICE', 1, 1, 1, NULL),
('age', 'Age', 'How old are you?', 'Your age helps us tailor your plan.', 'AGE', 'NUMBER', 2, 1, 1, NULL),
('weight', 'Weight', 'What is your current weight?', 'Your weight helps us calculate the right load.', 'WEIGHT', 'NUMBER', 3, 1, 1, NULL),
('height', 'Height', 'How tall are you?', 'Your height helps us tailor your plan.', 'HEIGHT', 'NUMBER', 4, 1, 1, NULL),
('fitness_level', 'Fitness Level', 'How would you describe your experience?', 'This helps us recommend the right intensity.', 'FITNESS_LEVEL', 'SINGLE_CHOICE', 5, 1, 1, NULL),
('fitness_goal', 'Fitness Goal', 'What do you want to achieve?', 'Select your primary goal.', 'FITNESS_GOAL', 'MULTIPLE_CHOICE', 6, 1, 1, NULL),
('equipment', 'Equipment', 'What do you have access to?', 'We will suggest workouts that match your gear.', 'EQUIPMENT', 'MULTIPLE_CHOICE', 7, 1, 1, NULL),
('schedule', 'Schedule', 'When can you work out?', 'Pick your preferred days and time.', 'SCHEDULE', 'MULTIPLE_CHOICE', 8, 1, 1, NULL),
('health_limitations', 'Health & Limitations', 'Any we should know about?', 'Optional - helps us keep you safe.', 'HEALTH_LIMITATIONS', 'MULTIPLE_CHOICE', 9, 0, 1, NULL),
('notifications', 'Notifications', 'Stay on track', 'Choose what reminders you want.', 'NOTIFICATIONS', 'TOGGLE', 10, 0, 1, NULL);

-- Onboarding options: GENDER
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'female', 'Female', 'Female', 1, 1 FROM onboarding_step WHERE step_key = 'gender' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'male', 'Male', 'Male', 2, 1 FROM onboarding_step WHERE step_key = 'gender' LIMIT 1;

-- Onboarding options: FITNESS_LEVEL
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'beginner', 'Beginner', 'New to fitness or returning after a break', 1, 1 FROM onboarding_step WHERE step_key = 'fitness_level' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'intermediate', 'Intermediate', '1-3 years of consistent training', 2, 1 FROM onboarding_step WHERE step_key = 'fitness_level' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'advanced', 'Advanced', '3+ years of structured training', 3, 1 FROM onboarding_step WHERE step_key = 'fitness_level' LIMIT 1;

-- Onboarding options: FITNESS_GOAL (with goal_id FK)
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active, goal_id)
SELECT step_id, 'build_muscle', 'Build Muscle', 'Hypertrophy-focused training', 1, 1, 
    (SELECT goal_id FROM goal WHERE goal_name = 'Build Muscle' LIMIT 1)
FROM onboarding_step WHERE step_key = 'fitness_goal' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active, goal_id)
SELECT step_id, 'lose_fat', 'Lose Fat', 'Fat loss with resistance training', 2, 1,
    (SELECT goal_id FROM goal WHERE goal_name = 'Lose Fat' LIMIT 1)
FROM onboarding_step WHERE step_key = 'fitness_goal' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active, goal_id)
SELECT step_id, 'increase_strength', 'Increase Strength', 'Heavy compound lifts', 3, 1,
    (SELECT goal_id FROM goal WHERE goal_name = 'Increase Strength' LIMIT 1)
FROM onboarding_step WHERE step_key = 'fitness_goal' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active, goal_id)
SELECT step_id, 'build_endurance', 'Build Endurance', 'Higher reps and stamina', 4, 1,
    (SELECT goal_id FROM goal WHERE goal_name = 'Build Endurance' LIMIT 1)
FROM onboarding_step WHERE step_key = 'fitness_goal' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active, goal_id)
SELECT step_id, 'general_fitness', 'General Fitness', 'Balanced approach', 5, 1,
    (SELECT goal_id FROM goal WHERE goal_name = 'General Fitness' LIMIT 1)
FROM onboarding_step WHERE step_key = 'fitness_goal' LIMIT 1;

-- Onboarding options: EQUIPMENT
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'dumbbells', 'Dumbbells', 'Hand weights only', 1, 1 FROM onboarding_step WHERE step_key = 'equipment' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'barbell', 'Barbell', 'Barbell and plates', 2, 1 FROM onboarding_step WHERE step_key = 'equipment' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'resistance_bands', 'Resistance Bands', 'Bands and bodyweight', 3, 1 FROM onboarding_step WHERE step_key = 'equipment' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'bodyweight', 'Bodyweight', 'No equipment', 4, 1 FROM onboarding_step WHERE step_key = 'equipment' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'full_gym', 'Full Gym', 'Full access to gym equipment', 5, 1 FROM onboarding_step WHERE step_key = 'equipment' LIMIT 1;

-- Onboarding options: HEALTH_LIMITATIONS
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'none', 'None', 'No limitations', 1, 1 FROM onboarding_step WHERE step_key = 'health_limitations' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'back', 'Back', 'Lower or upper back issues', 2, 1 FROM onboarding_step WHERE step_key = 'health_limitations' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'knee', 'Knee', 'Knee pain or injury', 3, 1 FROM onboarding_step WHERE step_key = 'health_limitations' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'shoulder', 'Shoulder', 'Shoulder pain or limited mobility', 4, 1 FROM onboarding_step WHERE step_key = 'health_limitations' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'cardiac', 'Cardiac', 'Heart or blood pressure considerations', 5, 1 FROM onboarding_step WHERE step_key = 'health_limitations' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'other', 'Other', 'Other limitations', 6, 1 FROM onboarding_step WHERE step_key = 'health_limitations' LIMIT 1;

-- Onboarding options: SCHEDULE (time of day)
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'morning', 'Morning', 'Before noon', 1, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'afternoon', 'Afternoon', '12pm - 5pm', 2, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'evening', 'Evening', 'After 5pm', 3, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;
-- SCHEDULE: days per week
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'days_3', '3 days/week', 'Three workouts per week', 4, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'days_4', '4 days/week', 'Four workouts per week', 5, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'days_5', '5 days/week', 'Five workouts per week', 6, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'days_6', '6 days/week', 'Six workouts per week', 7, 1 FROM onboarding_step WHERE step_key = 'schedule' LIMIT 1;

-- Onboarding options: NOTIFICATIONS
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'workout_reminders', 'Workout Reminders', 'Remind me to work out', 1, 1 FROM onboarding_step WHERE step_key = 'notifications' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'rest_day', 'Rest Day', 'Remind me to rest and recover', 2, 1 FROM onboarding_step WHERE step_key = 'notifications' LIMIT 1;
INSERT IGNORE INTO onboarding_option (step_id, option_key, label, description, display_order, is_active)
SELECT step_id, 'achievements', 'Achievements', 'Notify when I earn achievements', 3, 1 FROM onboarding_step WHERE step_key = 'notifications' LIMIT 1;

-- =====================================================
-- 9. WORKOUT TEMPLATES (For Recommendation System)
-- =====================================================
INSERT IGNORE INTO workout_template (name, description, goal_type, experience_level, equipment_tags, days_per_week, intensity_level, primary_muscle_groups, contraindications, metadata, is_active, created_at, updated_at) VALUES
-- Beginner Templates
('Full Body Beginner', '3-day full body workout focusing on compound movements for beginners. Perfect for building foundational strength and learning proper form.', 'MUSCLE_GAIN', 'BEGINNER', 'DUMBBELLS,BARBELL,BENCH', 3, 'MODERATE', 'CHEST,BACK,LEGS', NULL, NULL, true, NOW(), NOW()),
('Bodyweight Basics', 'No equipment needed! Master bodyweight movements to build strength and conditioning from home or anywhere.', 'GENERAL_FITNESS', 'BEGINNER', 'BODYWEIGHT', 3, 'LOW', 'FULL_BODY', 'LOWER_BACK_PAIN', NULL, true, NOW(), NOW()),
('Upper/Lower Split Beginner', '4-day beginner-friendly split alternating upper and lower body workouts.', 'BUILD_MUSCLE', 'BEGINNER', 'DUMBBELLS,BARBELL,BENCH,CABLE_MACHINE', 4, 'MODERATE', 'FULL_BODY', NULL, NULL, true, NOW(), NOW()),
('Fat Loss Starter', 'High-volume circuit training with minimal rest to maximize calorie burn while building muscle.', 'FAT_LOSS', 'BEGINNER', 'DUMBBELLS,BODYWEIGHT', 4, 'HIGH', 'FULL_BODY', 'CARDIAC', NULL, true, NOW(), NOW()),

-- Intermediate Templates
('Push Pull Legs', '6-day intermediate split dividing workouts by movement patterns for optimal recovery and growth.', 'MUSCLE_GAIN', 'INTERMEDIATE', 'DUMBBELLS,BARBELL,CABLE_MACHINE,BENCH', 6, 'HIGH', 'CHEST,BACK,LEGS,SHOULDERS', NULL, NULL, true, NOW(), NOW()),
('Upper/Lower Hypertrophy', '4-day split focusing on muscle building with controlled tempo and progressive overload.', 'BUILD_MUSCLE', 'INTERMEDIATE', 'DUMBBELLS,BARBELL,CABLE_MACHINE,MACHINES', 4, 'HIGH', 'FULL_BODY', NULL, NULL, true, NOW(), NOW()),
('Strength Builder 5x5', '3-day compound-focused program using 5x5 protocol for building raw strength.', 'STRENGTH', 'INTERMEDIATE', 'BARBELL,BENCH', 3, 'HIGH', 'CHEST,BACK,LEGS', 'LOWER_BACK_PAIN,SHOULDER_INJURY', NULL, true, NOW(), NOW()),
('Athletic Performance', '5-day program combining strength, power, and explosive movements for athletes.', 'ATHLETIC_PERFORMANCE', 'INTERMEDIATE', 'DUMBBELLS,BARBELL,PLYOMETRIC,BODYWEIGHT', 5, 'HIGH', 'FULL_BODY', 'KNEE_PAIN', NULL, true, NOW(), NOW()),
('Endurance Circuit', '5-day high-rep circuit training to build muscular endurance and cardiovascular fitness.', 'ENDURANCE', 'INTERMEDIATE', 'DUMBBELLS,RESISTANCE_BANDS,BODYWEIGHT', 5, 'MODERATE', 'FULL_BODY', 'CARDIAC', NULL, true, NOW(), NOW()),

-- Advanced Templates
('Advanced PPL Volume', '6-day push/pull/legs with high volume and intensity for experienced lifters seeking maximum hypertrophy.', 'MUSCLE_GAIN', 'ADVANCED', 'DUMBBELLS,BARBELL,CABLE_MACHINE,MACHINES,BENCH', 6, 'HIGH', 'CHEST,BACK,LEGS,SHOULDERS,ARMS', 'SHOULDER_INJURY', NULL, true, NOW(), NOW()),
('Powerlifting Focus', '4-day powerlifting program prioritizing squat, bench, and deadlift with accessory work.', 'STRENGTH', 'ADVANCED', 'BARBELL,BENCH,WEIGHT_BELT', 4, 'HIGH', 'CHEST,BACK,LEGS', 'LOWER_BACK_PAIN,SHOULDER_INJURY,KNEE_PAIN', NULL, true, NOW(), NOW()),
('Bodybuilding Split', '5-day bodybuilding split hitting each muscle group once per week with high volume.', 'BUILD_MUSCLE', 'ADVANCED', 'DUMBBELLS,BARBELL,CABLE_MACHINE,MACHINES', 5, 'HIGH', 'CHEST,BACK,SHOULDERS,ARMS,LEGS', NULL, NULL, true, NOW(), NOW()),
('Advanced Full Body', '3-day full body program for advanced lifters wanting efficiency without sacrificing results.', 'MUSCLE_GAIN', 'ADVANCED', 'DUMBBELLS,BARBELL,CABLE_MACHINE', 3, 'HIGH', 'FULL_BODY', NULL, NULL, true, NOW(), NOW()),

-- Specialized Templates
('Home Workout Minimal Equipment', '4-day program designed for home training with just dumbbells and resistance bands.', 'GENERAL_FITNESS', 'INTERMEDIATE', 'DUMBBELLS,RESISTANCE_BANDS,BODYWEIGHT', 4, 'MODERATE', 'FULL_BODY', NULL, NULL, true, NOW(), NOW()),
('Senior Fitness', '3-day low-impact program for older adults focusing on functional strength and mobility.', 'GENERAL_FITNESS', 'BEGINNER', 'DUMBBELLS,RESISTANCE_BANDS,BODYWEIGHT', 3, 'LOW', 'FULL_BODY', 'LOWER_BACK_PAIN,KNEE_PAIN,SHOULDER_INJURY', NULL, true, NOW(), NOW()),
('Rehabilitation Focused', '2-day gentle program for those recovering from injury, focusing on safe movements.', 'GENERAL_FITNESS', 'BEGINNER', 'RESISTANCE_BANDS,BODYWEIGHT', 2, 'LOW', 'FULL_BODY', 'LOWER_BACK_PAIN,KNEE_PAIN,SHOULDER_INJURY', NULL, true, NOW(), NOW()),
('Calisthenics Mastery', '5-day advanced bodyweight program for building strength and mastering gymnastic movements.', 'STRENGTH', 'ADVANCED', 'BODYWEIGHT,PULL_UP_BAR,DIP_STATION', 5, 'HIGH', 'FULL_BODY', 'SHOULDER_INJURY', NULL, true, NOW(), NOW()),
('Kettlebell Total Body', '3-day kettlebell-focused program for functional strength and conditioning.', 'GENERAL_FITNESS', 'INTERMEDIATE', 'KETTLEBELL,BODYWEIGHT', 3, 'MODERATE', 'FULL_BODY', 'LOWER_BACK_PAIN', NULL, true, NOW(), NOW());
-- =====================================================
-- 10. MEAL TEMPLATES (Standalone system-level templates)
-- =====================================================
INSERT IGNORE INTO meal_template (meal_name, source, meal_type, description, calories, proteinG, carbsG, fatsG, recipe_instructions) VALUES
-- ===== BREAKFAST (10) =====
('Classic Oatmeal & Eggs', 'SYSTEM', 'BREAKFAST', 'A hearty breakfast combining slow-digesting oats with protein-rich eggs for sustained energy.', 450, 30.0, 45.0, 15.0,
 'Ingredients:\n- 80g rolled oats\n- 3 whole eggs\n- 1 banana\n- 1 tbsp honey\n- Pinch of cinnamon\n\nInstructions:\n1. Cook oats with water or milk until creamy\n2. Scramble or fry eggs to your preference\n3. Top oats with sliced banana, honey, and cinnamon\n4. Serve eggs on the side'),

('Greek Yogurt Protein Bowl', 'SYSTEM', 'BREAKFAST', 'A quick, high-protein breakfast bowl loaded with antioxidants and healthy fats.', 400, 35.0, 40.0, 12.0,
 'Ingredients:\n- 200g Greek yogurt (0% fat)\n- 30g granola\n- 1 scoop whey protein\n- 100g mixed berries\n- 15g almonds\n- 1 tsp chia seeds\n\nInstructions:\n1. Mix protein powder into Greek yogurt\n2. Top with granola, berries, almonds, and chia seeds\n3. Drizzle with a little honey if desired'),

('Avocado Toast & Turkey', 'SYSTEM', 'BREAKFAST', 'Modern classic breakfast with wholesome fats and lean protein from turkey slices.', 420, 28.0, 35.0, 18.0,
 'Ingredients:\n- 2 slices whole grain bread\n- 1/2 ripe avocado\n- 100g turkey breast slices\n- 1 egg (poached or fried)\n- Cherry tomatoes\n- Salt, pepper, red pepper flakes\n\nInstructions:\n1. Toast bread until golden\n2. Mash avocado and spread on toast\n3. Layer turkey slices on top\n4. Add poached/fried egg\n5. Season with salt, pepper, and red pepper flakes\n6. Serve with cherry tomatoes on the side'),

('Protein Pancakes', 'SYSTEM', 'BREAKFAST', 'Fluffy pancakes packed with protein - perfect pre-workout fuel.', 480, 32.0, 50.0, 14.0,
 'Ingredients:\n- 80g oat flour\n- 1 scoop protein powder (vanilla)\n- 2 eggs\n- 100ml milk\n- 1 banana (mashed)\n- 1 tsp baking powder\n- 15g peanut butter\n- Fresh berries\n\nInstructions:\n1. Blend oat flour, protein powder, eggs, milk, banana, and baking powder\n2. Cook on non-stick pan over medium heat\n3. Flip when bubbles appear\n4. Stack and top with peanut butter and berries'),

('Egg & Veggie Scramble', 'SYSTEM', 'BREAKFAST', 'A vegetable-loaded egg scramble providing vitamins, minerals, and quality protein.', 380, 28.0, 20.0, 22.0,
 'Ingredients:\n- 4 eggs\n- 50g spinach\n- 50g bell peppers (diced)\n- 30g mushrooms (sliced)\n- 30g onion (diced)\n- 30g feta cheese\n- 1 tsp olive oil\n\nInstructions:\n1. Heat olive oil in pan over medium heat\n2. Saute onion and peppers for 2-3 minutes\n3. Add mushrooms and cook 2 minutes\n4. Add spinach, cook until wilted\n5. Pour in beaten eggs, stir gently\n6. Crumble feta on top and serve'),

('Overnight Protein Oats', 'SYSTEM', 'BREAKFAST', 'No-cook prep-ahead breakfast - grab from the fridge and go.', 430, 30.0, 48.0, 12.0,
 'Ingredients:\n- 70g rolled oats\n- 200ml almond milk\n- 1 scoop protein powder (chocolate)\n- 1 tbsp chia seeds\n- 1 tbsp cocoa powder\n- 1/2 banana (sliced)\n- 10g dark chocolate chips\n\nInstructions:\n1. Mix oats, milk, protein powder, chia seeds, and cocoa in a jar\n2. Stir well, seal, and refrigerate overnight\n3. In the morning top with banana slices and chocolate chips\n4. Eat cold or microwave 1-2 minutes'),

('Smoothie Power Bowl', 'SYSTEM', 'BREAKFAST', 'A thick, blended smoothie bowl with toppings for a refreshing high-protein breakfast.', 440, 32.0, 50.0, 10.0,
 'Ingredients:\n- 1 scoop protein powder (vanilla)\n- 1 frozen banana\n- 100g frozen mixed berries\n- 100ml almond milk\n- 20g granola\n- 10g coconut flakes\n- 1 tbsp pumpkin seeds\n\nInstructions:\n1. Blend protein powder, banana, berries, and milk until thick\n2. Pour into a bowl\n3. Top with granola, coconut flakes, and pumpkin seeds\n4. Eat immediately with a spoon'),

('Breakfast Burrito', 'SYSTEM', 'BREAKFAST', 'A filling breakfast burrito loaded with eggs, beans, cheese, and salsa for a savory start.', 520, 32.0, 48.0, 20.0,
 'Ingredients:\n- 1 large whole wheat tortilla\n- 3 eggs (scrambled)\n- 50g black beans (canned, drained)\n- 30g shredded cheddar cheese\n- 30g salsa\n- 1/4 avocado (sliced)\n- Hot sauce (optional)\n\nInstructions:\n1. Scramble eggs in a non-stick pan\n2. Warm tortilla in microwave for 15 seconds\n3. Layer eggs, beans, cheese, avocado, and salsa on tortilla\n4. Roll tightly, tucking ends in\n5. Optional: grill seam-side down for a crispy finish'),

('Cottage Cheese & Fruit Plate', 'SYSTEM', 'BREAKFAST', 'High-protein, low-effort breakfast with creamy cottage cheese and fresh seasonal fruits.', 350, 30.0, 38.0, 8.0,
 'Ingredients:\n- 200g cottage cheese (2% fat)\n- 1 peach or nectarine (sliced)\n- 80g blueberries\n- 15g walnuts\n- 1 tbsp honey\n- Mint leaves\n\nInstructions:\n1. Scoop cottage cheese into a bowl\n2. Arrange sliced peach and blueberries on top\n3. Sprinkle with walnuts\n4. Drizzle honey and garnish with mint\n5. Serve immediately'),

('Smoked Salmon Bagel', 'SYSTEM', 'BREAKFAST', 'A luxurious breakfast featuring omega-3 rich smoked salmon with cream cheese on a whole grain bagel.', 460, 30.0, 42.0, 18.0,
 'Ingredients:\n- 1 whole grain bagel\n- 80g smoked salmon\n- 30g cream cheese (light)\n- 1 tbsp capers\n- Red onion (thinly sliced)\n- Fresh dill\n- Lemon wedge\n\nInstructions:\n1. Slice and toast bagel until golden\n2. Spread cream cheese on both halves\n3. Layer smoked salmon on top\n4. Add capers and red onion slices\n5. Garnish with dill and a squeeze of lemon'),

-- ===== LUNCH (10) =====
('Grilled Chicken & Quinoa Bowl', 'SYSTEM', 'LUNCH', 'A balanced, macro-friendly bowl with lean protein, complex carbs, and fiber-rich vegetables.', 550, 42.0, 50.0, 16.0,
 'Ingredients:\n- 150g chicken breast\n- 80g quinoa (dry)\n- 100g broccoli\n- 50g cherry tomatoes\n- 1/2 avocado\n- Lemon juice, garlic, paprika\n\nInstructions:\n1. Season chicken with garlic, paprika, salt, and pepper\n2. Grill chicken 6-7 minutes per side until cooked through\n3. Cook quinoa in water for 15 minutes\n4. Steam broccoli until tender-crisp\n5. Slice chicken and arrange over quinoa\n6. Add tomatoes and avocado slices\n7. Drizzle with lemon juice'),

('Tuna & Brown Rice Plate', 'SYSTEM', 'LUNCH', 'Simple yet effective meal with omega-3 rich tuna and slow-release carbohydrates.', 500, 40.0, 52.0, 12.0,
 'Ingredients:\n- 150g canned tuna (in water, drained)\n- 80g brown rice (dry)\n- 100g mixed salad greens\n- 50g cucumber\n- 50g corn kernels\n- 1 tbsp olive oil\n- Lemon, salt, pepper\n\nInstructions:\n1. Cook brown rice according to package\n2. Drain tuna and mix with lemon juice and olive oil\n3. Arrange salad greens on plate\n4. Add rice, tuna, cucumber, and corn\n5. Season to taste'),

('Turkey Wrap with Veggies', 'SYSTEM', 'LUNCH', 'Portable, protein-packed wrap ideal for busy days - great for meal prep.', 480, 38.0, 42.0, 16.0,
 'Ingredients:\n- 1 large whole wheat tortilla\n- 120g turkey breast (sliced)\n- 30g hummus\n- 50g lettuce\n- 50g tomato (sliced)\n- 30g cucumber (sliced)\n- 30g shredded carrot\n\nInstructions:\n1. Spread hummus evenly on tortilla\n2. Layer turkey slices over hummus\n3. Add lettuce, tomato, cucumber, and carrot\n4. Roll tightly and cut in half\n5. Wrap in foil for on-the-go meals'),

('Salmon & Sweet Potato', 'SYSTEM', 'LUNCH', 'A nutrient-dense plate with omega-3-rich salmon and complex carbs from sweet potato.', 580, 38.0, 48.0, 22.0,
 'Ingredients:\n- 150g salmon fillet\n- 200g sweet potato\n- 100g asparagus\n- 1 tbsp olive oil\n- Lemon, garlic, dill\n\nInstructions:\n1. Preheat oven to 200C (400F)\n2. Cube sweet potato, toss with olive oil, and roast 25 minutes\n3. Season salmon with garlic, dill, and lemon\n4. Bake salmon for 12-15 minutes\n5. Steam or roast asparagus\n6. Plate everything together'),

('Chicken Stir-Fry Noodles', 'SYSTEM', 'LUNCH', 'Asian-inspired stir-fry with lean chicken, colorful vegetables, and whole grain noodles.', 520, 40.0, 55.0, 14.0,
 'Ingredients:\n- 150g chicken breast (sliced thin)\n- 80g whole wheat noodles\n- 50g bell peppers (mixed colors)\n- 50g broccoli\n- 30g carrot (julienned)\n- 2 tbsp soy sauce (low sodium)\n- 1 tsp sesame oil\n- 1 clove garlic, ginger\n\nInstructions:\n1. Cook noodles according to package, drain\n2. Heat sesame oil in wok over high heat\n3. Stir-fry chicken with garlic and ginger 4-5 minutes\n4. Add vegetables, cook 3-4 minutes\n5. Add noodles and soy sauce\n6. Toss everything together and serve'),

('Beef & Black Bean Bowl', 'SYSTEM', 'LUNCH', 'High-protein Tex-Mex style bowl with lean beef and fiber-rich black beans.', 560, 44.0, 48.0, 18.0,
 'Ingredients:\n- 130g lean ground beef (95% lean)\n- 80g black beans (canned, drained)\n- 80g brown rice (dry)\n- 50g corn\n- 30g diced tomatoes\n- 20g cheddar cheese\n- Cumin, chili powder, lime\n\nInstructions:\n1. Cook rice according to package\n2. Brown ground beef with cumin and chili powder\n3. Warm black beans and corn\n4. Build bowl: rice, beef, beans, corn, tomatoes\n5. Top with cheese and a squeeze of lime'),

('Lentil & Chickpea Buddha Bowl', 'SYSTEM', 'LUNCH', 'Plant-based powerhouse bowl with legumes, roasted veggies, and tahini dressing.', 510, 28.0, 60.0, 16.0,
 'Ingredients:\n- 80g green lentils (dry)\n- 80g chickpeas (canned, drained)\n- 100g roasted sweet potato cubes\n- 50g baby spinach\n- 50g cucumber\n- 1 tbsp tahini\n- Lemon juice, garlic\n\nInstructions:\n1. Cook lentils in salted water 20-25 minutes\n2. Roast sweet potato cubes at 200C for 20 minutes\n3. Make dressing: mix tahini, lemon juice, garlic, and water\n4. Arrange spinach, lentils, chickpeas, sweet potato, cucumber in a bowl\n5. Drizzle with tahini dressing'),

('Mediterranean Chicken Salad', 'SYSTEM', 'LUNCH', 'Fresh and vibrant salad with grilled chicken, olives, feta, and a tangy vinaigrette.', 490, 40.0, 28.0, 24.0,
 'Ingredients:\n- 150g chicken breast (grilled, sliced)\n- 80g mixed greens\n- 50g cucumber (diced)\n- 40g cherry tomatoes\n- 30g kalamata olives\n- 30g feta cheese\n- 30g red onion (sliced)\n- 1 tbsp olive oil, red wine vinegar, oregano\n\nInstructions:\n1. Grill and slice chicken breast\n2. Arrange mixed greens as base\n3. Top with cucumber, tomatoes, olives, onion, and feta\n4. Add sliced chicken on top\n5. Whisk olive oil, vinegar, and oregano for dressing\n6. Drizzle dressing over salad'),

('Pork Tenderloin & Couscous', 'SYSTEM', 'LUNCH', 'Tender, lean pork paired with fluffy couscous and roasted Mediterranean vegetables.', 530, 42.0, 50.0, 14.0,
 'Ingredients:\n- 150g pork tenderloin\n- 80g couscous (dry)\n- 80g roasted bell peppers\n- 50g roasted zucchini\n- 30g sun-dried tomatoes\n- 1 tbsp olive oil\n- Paprika, garlic, cumin\n\nInstructions:\n1. Season pork with paprika, garlic, and cumin\n2. Sear pork in hot pan 3 min per side, then bake at 190C for 15 minutes\n3. Cook couscous in boiling water, cover 5 minutes, fluff\n4. Roast peppers and zucchini with olive oil\n5. Slice pork and serve over couscous with roasted veggies\n6. Garnish with sun-dried tomatoes'),

('Egg Fried Rice Bowl', 'SYSTEM', 'LUNCH', 'Quick and satisfying fried rice with eggs, vegetables, and a touch of sesame.', 470, 22.0, 58.0, 16.0,
 'Ingredients:\n- 150g cooked jasmine rice (cold)\n- 3 eggs (beaten)\n- 50g peas\n- 50g carrot (diced small)\n- 30g green onion (sliced)\n- 2 tbsp soy sauce (low sodium)\n- 1 tsp sesame oil\n- 1 clove garlic (minced)\n\nInstructions:\n1. Heat sesame oil in wok over high heat\n2. Scramble eggs, break into pieces, set aside\n3. Stir-fry garlic, carrots, and peas 2-3 minutes\n4. Add cold rice, toss on high heat 3-4 minutes\n5. Add soy sauce and scrambled eggs\n6. Garnish with green onion and serve'),

-- ===== DINNER (10) =====
('Baked Chicken Breast & Veggies', 'SYSTEM', 'DINNER', 'A lean, clean dinner with perfectly seasoned chicken and roasted seasonal vegetables.', 480, 42.0, 30.0, 18.0,
 'Ingredients:\n- 180g chicken breast\n- 100g broccoli\n- 100g zucchini\n- 50g bell pepper\n- 1 tbsp olive oil\n- Italian seasoning, garlic powder\n\nInstructions:\n1. Preheat oven to 200C (400F)\n2. Season chicken with Italian seasoning, garlic powder, salt, pepper\n3. Cut vegetables into even pieces\n4. Toss veggies in olive oil and seasoning\n5. Bake chicken and veggies on sheet pan for 25 minutes\n6. Let chicken rest 5 minutes before slicing'),

('Grilled Salmon with Steamed Rice', 'SYSTEM', 'DINNER', 'Heart-healthy salmon rich in omega-3s paired with jasmine rice and green beans.', 540, 38.0, 45.0, 20.0,
 'Ingredients:\n- 160g salmon fillet\n- 80g jasmine rice (dry)\n- 100g green beans\n- 1 tsp olive oil\n- Lemon, fresh dill, capers\n\nInstructions:\n1. Cook rice according to package\n2. Season salmon with salt, pepper, and dill\n3. Grill or pan-sear salmon 4-5 min per side\n4. Steam green beans until tender-crisp\n5. Plate rice, salmon, and beans\n6. Garnish with lemon wedge and capers'),

('Lean Beef Steak & Potatoes', 'SYSTEM', 'DINNER', 'Classic steak dinner with roasted baby potatoes and a side salad - great post-workout.', 600, 45.0, 45.0, 22.0,
 'Ingredients:\n- 180g sirloin steak (lean)\n- 200g baby potatoes\n- 50g mixed salad greens\n- 30g cherry tomatoes\n- 1 tbsp olive oil\n- Rosemary, garlic, salt, pepper\n\nInstructions:\n1. Boil or roast baby potatoes with rosemary until golden (25 min at 200C)\n2. Season steak generously with salt, pepper, and garlic\n3. Sear steak in hot pan 3-4 min per side (medium-rare)\n4. Rest steak for 5 minutes\n5. Serve with potatoes and a simple side salad'),

('Shrimp & Zucchini Noodles', 'SYSTEM', 'DINNER', 'Low-carb, high-protein dinner using spiralized zucchini as a pasta alternative.', 380, 35.0, 18.0, 18.0,
 'Ingredients:\n- 180g shrimp (peeled, deveined)\n- 2 medium zucchini (spiralized)\n- 50g cherry tomatoes (halved)\n- 2 cloves garlic (minced)\n- 1 tbsp olive oil\n- 30g parmesan cheese\n- Fresh basil, red pepper flakes\n\nInstructions:\n1. Heat olive oil in pan, saute garlic 30 seconds\n2. Cook shrimp 2-3 min per side until pink\n3. Remove shrimp, add zucchini noodles and tomatoes\n4. Cook 2-3 minutes until just tender\n5. Return shrimp to pan, toss together\n6. Top with parmesan, basil, and red pepper flakes'),

('Turkey Meatballs with Pasta', 'SYSTEM', 'DINNER', 'Lean turkey meatballs in marinara sauce over whole grain pasta - comfort food made healthy.', 560, 40.0, 55.0, 16.0,
 'Ingredients:\n- 150g ground turkey\n- 80g whole wheat pasta\n- 100ml marinara sauce\n- 1 egg (for binding)\n- 20g breadcrumbs\n- Italian herbs, garlic\n- 20g parmesan\n\nInstructions:\n1. Mix ground turkey with egg, breadcrumbs, garlic, Italian herbs\n2. Form into 6-8 meatballs\n3. Bake meatballs at 190C for 20 minutes\n4. Cook pasta according to package\n5. Warm marinara sauce, add meatballs\n6. Serve meatballs and sauce over pasta\n7. Top with grated parmesan'),

('Tofu & Vegetable Curry', 'SYSTEM', 'DINNER', 'A flavorful plant-based dinner with creamy coconut curry and protein-rich tofu.', 470, 24.0, 42.0, 22.0,
 'Ingredients:\n- 200g firm tofu (pressed, cubed)\n- 100ml light coconut milk\n- 80g brown rice (dry)\n- 100g mixed vegetables (peppers, peas, carrots)\n- 2 tbsp curry paste (red or yellow)\n- 1 tbsp coconut oil\n- Fresh cilantro, lime\n\nInstructions:\n1. Cook rice according to package\n2. Press and cube tofu, pan-fry until golden\n3. Saute curry paste in coconut oil 1 minute\n4. Add coconut milk and vegetables, simmer 10 minutes\n5. Add tofu, cook 5 more minutes\n6. Serve curry over rice\n7. Garnish with cilantro and lime wedge'),

('Herb-Crusted Cod with Quinoa', 'SYSTEM', 'DINNER', 'Light yet satisfying white fish dinner with herbed crust and fluffy quinoa pilaf.', 450, 38.0, 40.0, 14.0,
 'Ingredients:\n- 170g cod fillet\n- 80g quinoa (dry)\n- 100g spinach\n- 30g breadcrumbs\n- Fresh parsley, dill\n- 1 tbsp olive oil\n- Lemon, garlic\n\nInstructions:\n1. Cook quinoa in vegetable broth for 15 minutes\n2. Mix breadcrumbs with chopped herbs, garlic, and olive oil\n3. Press herb mixture onto cod fillet\n4. Bake at 200C for 15-18 minutes until flaky\n5. Saute spinach with garlic until wilted\n6. Plate quinoa, spinach, and cod\n7. Squeeze fresh lemon over fish'),

('Chicken Fajita Bowl', 'SYSTEM', 'DINNER', 'Colorful Tex-Mex fajita bowl with seasoned chicken strips, peppers, and cilantro-lime rice.', 550, 40.0, 52.0, 18.0,
 'Ingredients:\n- 160g chicken breast (sliced into strips)\n- 80g jasmine rice (dry)\n- 80g bell peppers (mixed, sliced)\n- 50g onion (sliced)\n- 30g sour cream (light)\n- 1 tbsp olive oil\n- Cumin, chili powder, lime, cilantro\n\nInstructions:\n1. Cook rice, then stir in chopped cilantro and lime juice\n2. Season chicken with cumin, chili powder, salt, and pepper\n3. Saute chicken strips in olive oil over high heat 5-6 minutes\n4. Cook peppers and onion until slightly charred\n5. Build bowl: cilantro-lime rice, chicken, peppers, onion\n6. Top with sour cream and a lime wedge'),

('Lamb Kofta with Tabbouleh', 'SYSTEM', 'DINNER', 'Middle Eastern-inspired dinner with spiced lamb kofta and refreshing parsley tabbouleh.', 520, 36.0, 40.0, 24.0,
 'Ingredients:\n- 150g ground lamb (lean)\n- 60g bulgur wheat\n- 50g parsley (finely chopped)\n- 50g tomato (diced)\n- 30g cucumber (diced)\n- 30g red onion (diced)\n- 1 tbsp olive oil\n- Cumin, coriander, mint, lemon\n\nInstructions:\n1. Mix lamb with cumin, coriander, salt, pepper, and minced onion\n2. Shape into small kofta sausages or patties\n3. Grill or pan-fry kofta 4-5 min per side\n4. Soak bulgur in boiling water 15 minutes, drain and cool\n5. Mix bulgur with parsley, tomato, cucumber, onion, olive oil, and lemon juice\n6. Serve kofta alongside tabbouleh'),

('Stuffed Bell Peppers', 'SYSTEM', 'DINNER', 'Colorful bell peppers stuffed with a savory mix of ground turkey, rice, and vegetables.', 440, 34.0, 40.0, 16.0,
 'Ingredients:\n- 2 large bell peppers (halved, seeds removed)\n- 120g ground turkey\n- 60g cooked brown rice\n- 50g diced tomatoes\n- 30g corn kernels\n- 30g shredded mozzarella\n- Italian herbs, garlic, onion\n\nInstructions:\n1. Preheat oven to 190C (375F)\n2. Brown turkey with garlic and onion\n3. Mix turkey with rice, tomatoes, corn, and herbs\n4. Stuff pepper halves with mixture\n5. Top with shredded mozzarella\n6. Bake for 25-30 minutes until peppers are tender\n7. Let cool 5 minutes before serving'),

-- ===== SNACK (10) =====
('Protein Shake - Classic', 'SYSTEM', 'SNACK', 'A simple, fast-absorbing protein shake perfect for between meals or post-workout.', 200, 30.0, 12.0, 4.0,
 'Ingredients:\n- 1.5 scoops whey protein (vanilla or chocolate)\n- 250ml water or almond milk\n- 1/2 banana (optional)\n- Ice cubes\n\nInstructions:\n1. Add liquid, protein powder, and banana to shaker or blender\n2. Blend or shake until smooth\n3. Serve immediately'),

('PB & Banana Rice Cakes', 'SYSTEM', 'SNACK', 'Crunchy rice cakes topped with peanut butter and banana for a quick energy boost.', 250, 10.0, 30.0, 12.0,
 'Ingredients:\n- 2 plain rice cakes\n- 2 tbsp natural peanut butter\n- 1 small banana (sliced)\n- Drizzle of honey\n- Pinch of sea salt\n\nInstructions:\n1. Spread peanut butter evenly on each rice cake\n2. Top with banana slices\n3. Drizzle with honey and sprinkle sea salt\n4. Eat immediately'),

('Trail Mix Power Pack', 'SYSTEM', 'SNACK', 'A portable, calorie-dense snack mix with nuts, seeds, and dried fruits for sustained energy.', 280, 10.0, 24.0, 18.0,
 'Ingredients:\n- 20g almonds\n- 15g cashews\n- 10g pumpkin seeds\n- 15g dried cranberries\n- 10g dark chocolate chips\n- 10g coconut flakes\n\nInstructions:\n1. Combine all ingredients in a small container or bag\n2. Shake to mix\n3. Portion into snack bags for the week\n4. Store in a cool, dry place'),

('Hard Boiled Eggs & Hummus', 'SYSTEM', 'SNACK', 'Simple high-protein snack pairing eggs with creamy hummus and fresh vegetables.', 220, 18.0, 10.0, 14.0,
 'Ingredients:\n- 2 hard-boiled eggs\n- 40g hummus\n- 50g carrot sticks\n- 50g celery sticks\n- Paprika, salt\n\nInstructions:\n1. Boil eggs for 10-12 minutes, then ice bath and peel\n2. Slice eggs in half, sprinkle with paprika and salt\n3. Serve with hummus and veggie sticks for dipping'),

('Cottage Cheese & Pineapple', 'SYSTEM', 'SNACK', 'A sweet and savory high-protein snack with tropical flavor.', 180, 20.0, 18.0, 3.0,
 'Ingredients:\n- 150g cottage cheese (2% fat)\n- 80g fresh pineapple chunks\n- 1 tsp honey\n- Pinch of cinnamon\n\nInstructions:\n1. Scoop cottage cheese into a bowl\n2. Top with pineapple chunks\n3. Drizzle with honey and dust with cinnamon\n4. Eat chilled'),

('Apple Slices with Almond Butter', 'SYSTEM', 'SNACK', 'A satisfying combination of crisp apple and rich almond butter for healthy fats and fiber.', 230, 6.0, 28.0, 12.0,
 'Ingredients:\n- 1 medium apple (sliced)\n- 2 tbsp almond butter\n- 1 tsp chia seeds\n- Pinch of cinnamon\n\nInstructions:\n1. Wash and slice apple into wedges\n2. Serve with almond butter for dipping\n3. Sprinkle chia seeds and cinnamon on almond butter\n4. Eat immediately to prevent browning'),

('Tuna Cucumber Bites', 'SYSTEM', 'SNACK', 'Light, refreshing, and high-protein snack using cucumber rounds as a cracker substitute.', 160, 22.0, 6.0, 6.0,
 'Ingredients:\n- 1 large cucumber (sliced into thick rounds)\n- 100g canned tuna (in water, drained)\n- 1 tbsp Greek yogurt\n- 1 tsp Dijon mustard\n- Salt, pepper, fresh dill\n\nInstructions:\n1. Slice cucumber into 1cm thick rounds\n2. Mix tuna with Greek yogurt, mustard, salt, and pepper\n3. Spoon tuna mixture onto each cucumber round\n4. Garnish with dill and serve'),

('Edamame with Sea Salt', 'SYSTEM', 'SNACK', 'Simple steamed edamame pods lightly salted - a plant-based protein snack staple.', 190, 17.0, 14.0, 8.0,
 'Ingredients:\n- 200g frozen edamame (in pods)\n- 1 tsp sea salt\n- 1 tsp sesame oil (optional)\n- Red pepper flakes (optional)\n\nInstructions:\n1. Boil edamame for 4-5 minutes or microwave for 3 minutes\n2. Drain and toss with sea salt\n3. Optional: drizzle sesame oil and sprinkle red pepper flakes\n4. Pop beans out of shells to eat'),

('Protein Energy Balls', 'SYSTEM', 'SNACK', 'No-bake energy balls made with oats, protein powder, and nut butter - great for meal prep.', 210, 14.0, 22.0, 10.0,
 'Ingredients:\n- 50g rolled oats\n- 1 scoop protein powder (chocolate)\n- 2 tbsp peanut butter\n- 1 tbsp honey\n- 1 tbsp mini chocolate chips\n- 1 tbsp flax seeds\n\nInstructions:\n1. Mix all ingredients in a bowl until combined\n2. If too dry, add a splash of milk\n3. Roll into 6-8 small balls\n4. Refrigerate for at least 30 minutes\n5. Store in fridge for up to 5 days'),

('Greek Yogurt & Honey Cup', 'SYSTEM', 'SNACK', 'A creamy, protein-rich snack with natural sweetness from honey and crunch from walnuts.', 200, 18.0, 20.0, 6.0,
 'Ingredients:\n- 150g Greek yogurt (0% fat)\n- 1 tbsp honey\n- 15g walnuts (crushed)\n- 1 tsp vanilla extract\n\nInstructions:\n1. Spoon yogurt into a cup or bowl\n2. Stir in vanilla extract\n3. Drizzle honey on top\n4. Sprinkle crushed walnuts\n5. Enjoy immediately or chill for later'),

-- ===== PRE_WORKOUT (5) =====
('Banana & Oat Energy Smoothie', 'SYSTEM', 'PRE_WORKOUT', 'Quick-digesting carbs and moderate protein for fuel 30-60 minutes before training.', 340, 20.0, 52.0, 6.0,
 'Ingredients:\n- 1 ripe banana\n- 40g rolled oats\n- 200ml milk\n- 1/2 scoop whey protein\n- 1 tbsp honey\n- Pinch of cinnamon\n\nInstructions:\n1. Blend all ingredients until smooth\n2. Drink 30-60 minutes before workout\n3. Avoid adding fats to keep digestion fast'),

('PB&J Toast', 'SYSTEM', 'PRE_WORKOUT', 'Simple pre-workout toast combining fast carbs with a touch of protein and healthy fats.', 320, 12.0, 42.0, 12.0,
 'Ingredients:\n- 2 slices white bread\n- 1 tbsp peanut butter\n- 1 tbsp strawberry jam\n\nInstructions:\n1. Toast bread lightly\n2. Spread peanut butter on one slice\n3. Spread jam on the other\n4. Press together and eat 30-45 minutes before training'),

('Rice Cake & Honey Stack', 'SYSTEM', 'PRE_WORKOUT', 'Ultra-light, fast-digesting pre-workout snack for quick energy with no stomach discomfort.', 220, 4.0, 48.0, 2.0,
 'Ingredients:\n- 3 plain rice cakes\n- 2 tbsp honey\n- Pinch of sea salt\n- Optional: 1/2 banana (sliced)\n\nInstructions:\n1. Stack rice cakes or serve separately\n2. Drizzle honey generously over each\n3. Add banana slices if desired\n4. Sprinkle sea salt for electrolytes\n5. Eat 20-30 minutes before workout'),

('Oatmeal Raisin Energy Bowl', 'SYSTEM', 'PRE_WORKOUT', 'Warm, comforting bowl of oats with natural sugars from raisins for sustained workout energy.', 380, 14.0, 62.0, 8.0,
 'Ingredients:\n- 70g rolled oats\n- 200ml water or milk\n- 30g raisins\n- 1 tbsp honey\n- 1 tsp cinnamon\n- 10g walnuts\n\nInstructions:\n1. Cook oats in water or milk until creamy\n2. Stir in raisins and cinnamon\n3. Top with honey and walnuts\n4. Eat 45-60 minutes before workout'),

('Fruit & Yogurt Parfait', 'SYSTEM', 'PRE_WORKOUT', 'Layered parfait with easily digestible carbs and a protein base for pre-training fuel.', 300, 18.0, 45.0, 6.0,
 'Ingredients:\n- 120g Greek yogurt (0% fat)\n- 80g mango chunks\n- 50g blueberries\n- 20g granola\n- 1 tsp honey\n\nInstructions:\n1. Layer yogurt in a glass or bowl\n2. Add mango and blueberries in layers\n3. Top with granola and honey\n4. Eat 30-45 minutes before training'),

-- ===== POST_WORKOUT (5) =====
('Chicken & White Rice Recovery', 'SYSTEM', 'POST_WORKOUT', 'Fast-absorbing carbs and lean protein to kickstart muscle recovery after intense training.', 500, 42.0, 55.0, 8.0,
 'Ingredients:\n- 160g chicken breast\n- 100g white jasmine rice (dry)\n- 1 tsp soy sauce\n- 1 tsp honey\n- Steamed broccoli (optional)\n\nInstructions:\n1. Cook rice according to package\n2. Season chicken with salt and pepper\n3. Grill or pan-sear chicken 5-6 min per side\n4. Slice chicken, drizzle with soy sauce and honey\n5. Serve over rice with optional steamed broccoli'),

('Whey Protein & Banana Shake', 'SYSTEM', 'POST_WORKOUT', 'Fast-digesting post-workout shake to rapidly deliver protein and glycogen replenishment.', 350, 35.0, 40.0, 5.0,
 'Ingredients:\n- 1.5 scoops whey protein (chocolate or vanilla)\n- 1 large banana\n- 250ml milk\n- 5g creatine monohydrate (optional)\n- Ice cubes\n\nInstructions:\n1. Add all ingredients to blender\n2. Blend until smooth and creamy\n3. Drink within 30 minutes of finishing workout'),

('Tuna Pasta Salad', 'SYSTEM', 'POST_WORKOUT', 'Protein and carb-rich cold pasta salad perfect for post-gym refueling and meal prep.', 480, 36.0, 55.0, 12.0,
 'Ingredients:\n- 120g canned tuna (drained)\n- 80g whole wheat pasta\n- 50g corn kernels\n- 50g cherry tomatoes (halved)\n- 30g red onion (diced)\n- 1 tbsp olive oil\n- Lemon juice, salt, pepper, parsley\n\nInstructions:\n1. Cook pasta al dente, drain and cool\n2. Mix tuna with olive oil and lemon juice\n3. Combine pasta, tuna, corn, tomatoes, and onion\n4. Season with salt, pepper, and chopped parsley\n5. Serve cold or at room temperature'),

('Egg White & Sweet Potato Plate', 'SYSTEM', 'POST_WORKOUT', 'Low-fat, high-protein recovery meal with complex carbs to restore glycogen stores.', 400, 34.0, 50.0, 6.0,
 'Ingredients:\n- 200g egg whites (about 6 egg whites)\n- 200g sweet potato\n- 50g spinach\n- Salt, pepper, hot sauce\n\nInstructions:\n1. Bake or microwave sweet potato until tender (about 8 min in microwave)\n2. Cook egg whites in non-stick pan, scramble or make an omelette\n3. Saute spinach briefly\n4. Plate sweet potato, egg whites, and spinach\n5. Season with salt, pepper, and hot sauce'),

('Chocolate Milk & Oat Bar', 'SYSTEM', 'POST_WORKOUT', 'The classic, research-backed post-workout combo - chocolate milk with a homemade oat bar.', 420, 22.0, 58.0, 12.0,
 'Ingredients:\n- 350ml chocolate milk\n- 50g rolled oats\n- 1 tbsp peanut butter\n- 1 tbsp honey\n- 15g dark chocolate chips\n- Pinch of salt\n\nInstructions:\n1. For the bar: Mix oats, peanut butter, honey, chocolate chips, and salt\n2. Press into a small container and refrigerate 1 hour\n3. Cut into bars\n4. Drink chocolate milk alongside the oat bar after workout\n5. Prep bars in batch for the week');
