-- =====================================================
-- GYM PLAN SEED DATA
-- Comprehensive seed data for gym workout application
-- =====================================================

-- =====================================================
-- 1. MUSCLE GROUPS (Reference data)
-- =====================================================
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

-- =====================================================
-- 2. EQUIPMENT (Reference data)
-- =====================================================
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
-- 5. EXERCISES (Comprehensive exercise library)
-- =====================================================
INSERT IGNORE INTO exercise (exercise_name, description, difficulty_level, exercise_type, instructions, video_url, image_url, calories_burned_per_min, requires_spotter, equipment_category) VALUES
-- CHEST EXERCISES
('Barbell Bench Press', 'The king of chest exercises. A compound movement that targets the pectoralis major while also engaging the anterior deltoids and triceps.', 'INTERMEDIATE', 'COMPOUND', '1. Lie flat on a bench with feet flat on the floor. 2. Grip the barbell slightly wider than shoulder-width. 3. Unrack the bar and lower it to your mid-chest. 4. Press the bar back up to full arm extension. 5. Keep your core tight and maintain a slight arch in your lower back.', '/videos/bench-press.mp4', '/images/bench-press.jpg', 8, true, 'FREE_WEIGHTS'),
('Incline Dumbbell Press', 'An upper chest-focused pressing movement that also engages the front deltoids. Great for building the clavicular head of the pecs.', 'INTERMEDIATE', 'COMPOUND', '1. Set bench to 30-45 degree incline. 2. Hold dumbbells at shoulder level with palms facing forward. 3. Press dumbbells up and together. 4. Lower slowly to starting position. 5. Keep core engaged throughout.', '/videos/incline-db-press.mp4', '/images/incline-db-press.jpg', 7, false, 'FREE_WEIGHTS'),
('Dumbbell Fly', 'An isolation exercise for the chest that emphasizes the stretch and contraction of the pectoralis major.', 'BEGINNER', 'ISOLATION', '1. Lie on a flat bench holding dumbbells above your chest. 2. With a slight bend in elbows, lower arms out to sides. 3. Feel a stretch in your chest at the bottom. 4. Squeeze chest muscles to bring arms back together. 5. Maintain the slight elbow bend throughout.', '/videos/db-fly.mp4', '/images/db-fly.jpg', 5, false, 'FREE_WEIGHTS'),
('Cable Crossover', 'A cable exercise providing constant tension throughout the movement for excellent chest isolation.', 'BEGINNER', 'ISOLATION', '1. Set cables at upper pulley position. 2. Stand in the middle with one foot forward. 3. With slight elbow bend, bring hands together in front. 4. Squeeze chest at the contracted position. 5. Slowly return to starting position.', '/videos/cable-crossover.mp4', '/images/cable-crossover.jpg', 6, false, 'MACHINE'),
('Push-Ups', 'A fundamental bodyweight exercise for building chest, shoulder, and tricep strength.', 'BEGINNER', 'COMPOUND', '1. Place hands slightly wider than shoulder-width on the floor. 2. Keep body in a straight line from head to heels. 3. Lower chest to the floor by bending elbows. 4. Push back up to starting position. 5. Keep core tight throughout the movement.', '/videos/pushups.mp4', '/images/pushups.jpg', 8, false, 'BODYWEIGHT'),
('Decline Bench Press', 'A pressing variation that emphasizes the lower portion of the pectoralis major.', 'INTERMEDIATE', 'COMPOUND', '1. Secure legs at the end of a decline bench. 2. Grip barbell slightly wider than shoulder-width. 3. Lower bar to lower chest. 4. Press bar back up to full extension. 5. Use a spotter for safety.', '/videos/decline-press.mp4', '/images/decline-press.jpg', 8, true, 'FREE_WEIGHTS'),
('Dips (Chest)', 'A compound movement targeting the lower chest, triceps, and shoulders.', 'INTERMEDIATE', 'COMPOUND', '1. Grip dip bars and lift yourself up. 2. Lean forward slightly to target chest. 3. Lower body until upper arms are parallel to floor. 4. Press back up to starting position. 5. Keep elbows slightly flared.', '/videos/chest-dips.mp4', '/images/chest-dips.jpg', 9, false, 'BODYWEIGHT'),

-- BACK EXERCISES
('Barbell Deadlift', 'The ultimate compound movement for overall back development, posterior chain strength, and total body power.', 'ADVANCED', 'COMPOUND', '1. Stand with feet hip-width apart, bar over mid-foot. 2. Hinge at hips and grip bar just outside legs. 3. Keep back flat, chest up, and core braced. 4. Drive through heels and extend hips and knees. 5. Stand tall, then lower with control.', '/videos/deadlift.mp4', '/images/deadlift.jpg', 10, false, 'FREE_WEIGHTS'),
('Pull-Ups', 'A fundamental bodyweight exercise for developing a wide, strong back.', 'INTERMEDIATE', 'COMPOUND', '1. Hang from bar with overhand grip wider than shoulders. 2. Pull yourself up until chin clears the bar. 3. Lower with control to full arm extension. 4. Keep core tight and avoid swinging. 5. Focus on pulling with your back, not arms.', '/videos/pullups.mp4', '/images/pullups.jpg', 9, false, 'BODYWEIGHT'),
('Barbell Row', 'A powerful compound movement for building overall back thickness and strength.', 'INTERMEDIATE', 'COMPOUND', '1. Hinge forward at hips, keeping back flat. 2. Grip barbell with overhand or underhand grip. 3. Pull bar to lower chest/upper abs. 4. Squeeze shoulder blades together at top. 5. Lower with control and repeat.', '/videos/barbell-row.mp4', '/images/barbell-row.jpg', 7, false, 'FREE_WEIGHTS'),
('Lat Pulldown', 'A machine exercise that mimics the pull-up movement, excellent for developing the lats.', 'BEGINNER', 'COMPOUND', '1. Sit at lat pulldown machine, thighs under pads. 2. Grip bar wider than shoulder-width. 3. Pull bar down to upper chest. 4. Squeeze lats at the bottom of the movement. 5. Control the weight back to start.', '/videos/lat-pulldown.mp4', '/images/lat-pulldown.jpg', 6, false, 'MACHINE'),
('Seated Cable Row', 'A machine exercise for mid-back thickness and development.', 'BEGINNER', 'COMPOUND', '1. Sit at cable row station with feet on platform. 2. Grip handle with arms extended. 3. Pull handle to lower chest. 4. Squeeze shoulder blades together. 5. Extend arms with control.', '/videos/seated-row.mp4', '/images/seated-row.jpg', 6, false, 'MACHINE'),
('Dumbbell Row', 'A unilateral back exercise that allows for full range of motion and muscle balance.', 'BEGINNER', 'COMPOUND', '1. Place one knee and hand on bench. 2. Hold dumbbell in opposite hand. 3. Pull dumbbell to hip, keeping elbow close. 4. Squeeze back muscles at top. 5. Lower with control and repeat.', '/videos/db-row.mp4', '/images/db-row.jpg', 6, false, 'FREE_WEIGHTS'),
('T-Bar Row', 'A compound rowing variation that allows for heavy loading and back development.', 'INTERMEDIATE', 'COMPOUND', '1. Straddle T-bar with feet hip-width apart. 2. Hinge forward and grip handles. 3. Pull weight to chest, keeping back flat. 4. Squeeze shoulder blades at top. 5. Lower with control.', '/videos/tbar-row.mp4', '/images/tbar-row.jpg', 7, false, 'FREE_WEIGHTS'),
('Face Pulls', 'An exercise targeting the rear deltoids and upper back for posture and shoulder health.', 'BEGINNER', 'ISOLATION', '1. Set cable to face height with rope attachment. 2. Grip rope with palms facing down. 3. Pull rope towards face, separating hands. 4. Squeeze rear delts at the end. 5. Return with control.', '/videos/face-pulls.mp4', '/images/face-pulls.jpg', 4, false, 'MACHINE'),

-- SHOULDER EXERCISES
('Overhead Press', 'The primary compound movement for shoulder development and pressing strength.', 'INTERMEDIATE', 'COMPOUND', '1. Start with bar at upper chest, feet shoulder-width. 2. Grip bar just outside shoulder-width. 3. Press bar straight up overhead. 4. Lock out arms at the top. 5. Lower with control to starting position.', '/videos/ohp.mp4', '/images/ohp.jpg', 7, true, 'FREE_WEIGHTS'),
('Dumbbell Shoulder Press', 'A versatile pressing movement that allows for natural arm path and unilateral work.', 'INTERMEDIATE', 'COMPOUND', '1. Sit on bench with back support. 2. Hold dumbbells at shoulder level. 3. Press dumbbells straight up. 4. Touch weights together at top. 5. Lower with control.', '/videos/db-shoulder-press.mp4', '/images/db-shoulder-press.jpg', 7, false, 'FREE_WEIGHTS'),
('Lateral Raises', 'An isolation exercise for developing the lateral deltoid for wider shoulders.', 'BEGINNER', 'ISOLATION', '1. Stand holding dumbbells at sides. 2. With slight elbow bend, raise arms to sides. 3. Lift until arms are parallel to floor. 4. Lower slowly with control. 5. Avoid using momentum.', '/videos/lateral-raises.mp4', '/images/lateral-raises.jpg', 4, false, 'FREE_WEIGHTS'),
('Front Raises', 'An isolation movement targeting the anterior deltoid.', 'BEGINNER', 'ISOLATION', '1. Stand holding dumbbells in front of thighs. 2. With slight elbow bend, raise one or both arms forward. 3. Lift to shoulder height. 4. Lower with control. 5. Keep core engaged.', '/videos/front-raises.mp4', '/images/front-raises.jpg', 4, false, 'FREE_WEIGHTS'),
('Reverse Fly', 'An isolation exercise for the posterior deltoid and upper back.', 'BEGINNER', 'ISOLATION', '1. Bend forward at hips, dumbbells hanging. 2. With slight elbow bend, raise arms to sides. 3. Squeeze rear delts at top. 4. Lower with control. 5. Keep back flat throughout.', '/videos/reverse-fly.mp4', '/images/reverse-fly.jpg', 4, false, 'FREE_WEIGHTS'),
('Arnold Press', 'A dumbbell pressing variation that works all three heads of the deltoid through rotation.', 'INTERMEDIATE', 'COMPOUND', '1. Start with dumbbells at shoulder level, palms facing you. 2. As you press up, rotate palms to face forward. 3. Lock out at the top. 4. Reverse the movement on the way down. 5. Maintain controlled tempo.', '/videos/arnold-press.mp4', '/images/arnold-press.jpg', 6, false, 'FREE_WEIGHTS'),
('Upright Row', 'A compound movement for the deltoids and trapezius.', 'INTERMEDIATE', 'COMPOUND', '1. Hold barbell with narrow grip in front of thighs. 2. Pull bar up close to body. 3. Lead with elbows, keep them high. 4. Lift to chin level. 5. Lower with control.', '/videos/upright-row.mp4', '/images/upright-row.jpg', 5, false, 'FREE_WEIGHTS'),
('Shrugs', 'An isolation exercise for the upper trapezius muscles.', 'BEGINNER', 'ISOLATION', '1. Hold heavy dumbbells or barbell at sides. 2. Shrug shoulders straight up towards ears. 3. Hold briefly at the top. 4. Lower slowly with control. 5. Avoid rolling shoulders.', '/videos/shrugs.mp4', '/images/shrugs.jpg', 4, false, 'FREE_WEIGHTS'),

-- ARM EXERCISES (Biceps)
('Barbell Curl', 'The classic bicep exercise for building overall arm mass.', 'BEGINNER', 'ISOLATION', '1. Stand holding barbell with underhand grip. 2. Keep elbows at sides and core tight. 3. Curl bar up to shoulder level. 4. Squeeze biceps at top. 5. Lower with control.', '/videos/barbell-curl.mp4', '/images/barbell-curl.jpg', 5, false, 'FREE_WEIGHTS'),
('Dumbbell Curl', 'A versatile bicep exercise allowing for various grip positions and unilateral work.', 'BEGINNER', 'ISOLATION', '1. Stand holding dumbbells at sides. 2. Curl weights up, supinating wrists. 3. Squeeze biceps at top. 4. Lower with control. 5. Alternate arms or curl simultaneously.', '/videos/db-curl.mp4', '/images/db-curl.jpg', 5, false, 'FREE_WEIGHTS'),
('Hammer Curl', 'A curl variation that targets the brachialis and forearms along with the biceps.', 'BEGINNER', 'ISOLATION', '1. Hold dumbbells with neutral grip (palms facing each other). 2. Curl weights up keeping neutral grip. 3. Squeeze at top. 4. Lower with control. 5. Keep elbows stationary.', '/videos/hammer-curl.mp4', '/images/hammer-curl.jpg', 5, false, 'FREE_WEIGHTS'),
('Preacher Curl', 'An isolation exercise that eliminates momentum for strict bicep work.', 'INTERMEDIATE', 'ISOLATION', '1. Sit at preacher bench with arms on pad. 2. Hold barbell or dumbbells with underhand grip. 3. Curl weight up. 4. Squeeze biceps at top. 5. Lower slowly, feeling the stretch.', '/videos/preacher-curl.mp4', '/images/preacher-curl.jpg', 4, false, 'FREE_WEIGHTS'),
('Concentration Curl', 'A strict isolation exercise for peak bicep contraction.', 'BEGINNER', 'ISOLATION', '1. Sit on bench, lean forward. 2. Brace elbow against inner thigh. 3. Curl dumbbell up to shoulder. 4. Squeeze hard at top. 5. Lower with control.', '/videos/concentration-curl.mp4', '/images/concentration-curl.jpg', 4, false, 'FREE_WEIGHTS'),
('Cable Curl', 'A bicep exercise providing constant tension throughout the movement.', 'BEGINNER', 'ISOLATION', '1. Stand facing cable machine with bar attachment. 2. Grip bar with underhand grip. 3. Curl bar up to shoulders. 4. Squeeze biceps. 5. Lower with control.', '/videos/cable-curl.mp4', '/images/cable-curl.jpg', 4, false, 'MACHINE'),

-- ARM EXERCISES (Triceps)
('Tricep Pushdown', 'A cable exercise for isolating the triceps.', 'BEGINNER', 'ISOLATION', '1. Stand at cable machine with rope or bar. 2. Keep elbows at sides. 3. Push weight down until arms are straight. 4. Squeeze triceps at bottom. 5. Return with control.', '/videos/tricep-pushdown.mp4', '/images/tricep-pushdown.jpg', 4, false, 'MACHINE'),
('Skull Crushers', 'A lying tricep extension that targets all three heads of the tricep.', 'INTERMEDIATE', 'ISOLATION', '1. Lie on bench holding EZ bar overhead. 2. Lower bar by bending elbows only. 3. Bring bar towards forehead or behind head. 4. Extend arms back up. 5. Keep upper arms stationary.', '/videos/skull-crushers.mp4', '/images/skull-crushers.jpg', 5, false, 'FREE_WEIGHTS'),
('Close-Grip Bench Press', 'A compound pressing movement emphasizing the triceps.', 'INTERMEDIATE', 'COMPOUND', '1. Lie on bench, grip bar with hands shoulder-width apart. 2. Lower bar to lower chest. 3. Keep elbows close to body. 4. Press bar back up. 5. Squeeze triceps at top.', '/videos/close-grip-bp.mp4', '/images/close-grip-bp.jpg', 7, true, 'FREE_WEIGHTS'),
('Overhead Tricep Extension', 'A tricep exercise emphasizing the long head of the tricep.', 'BEGINNER', 'ISOLATION', '1. Hold dumbbell overhead with both hands. 2. Lower weight behind head by bending elbows. 3. Keep upper arms close to ears. 4. Extend arms back up. 5. Squeeze triceps at top.', '/videos/oh-tricep-ext.mp4', '/images/oh-tricep-ext.jpg', 4, false, 'FREE_WEIGHTS'),
('Tricep Dips', 'A bodyweight exercise for building tricep and chest strength.', 'INTERMEDIATE', 'COMPOUND', '1. Grip parallel bars and lift yourself up. 2. Keep body upright to target triceps. 3. Lower until upper arms are parallel to floor. 4. Press back up to full extension. 5. Keep elbows close to body.', '/videos/tricep-dips.mp4', '/images/tricep-dips.jpg', 8, false, 'BODYWEIGHT'),
('Tricep Kickbacks', 'An isolation exercise for the tricep with emphasis on contraction.', 'BEGINNER', 'ISOLATION', '1. Hinge forward, arm bent at 90 degrees. 2. Keep upper arm parallel to floor. 3. Extend forearm back until arm is straight. 4. Squeeze tricep at full extension. 5. Lower with control.', '/videos/tricep-kickbacks.mp4', '/images/tricep-kickbacks.jpg', 3, false, 'FREE_WEIGHTS'),

-- LEG EXERCISES
('Barbell Squat', 'The king of leg exercises. A compound movement that targets the entire lower body.', 'INTERMEDIATE', 'COMPOUND', '1. Set bar on upper back, feet shoulder-width. 2. Brace core and keep chest up. 3. Sit back and down until thighs are parallel. 4. Drive through heels to stand. 5. Keep knees tracking over toes.', '/videos/squat.mp4', '/images/squat.jpg', 10, true, 'FREE_WEIGHTS'),
('Leg Press', 'A machine exercise for building leg size and strength with reduced spinal load.', 'BEGINNER', 'COMPOUND', '1. Sit in leg press with back flat against pad. 2. Place feet shoulder-width on platform. 3. Lower platform by bending knees. 4. Push through heels to extend legs. 5. Dont lock out knees at top.', '/videos/leg-press.mp4', '/images/leg-press.jpg', 8, false, 'MACHINE'),
('Romanian Deadlift', 'A hip hinge movement targeting the hamstrings and glutes.', 'INTERMEDIATE', 'COMPOUND', '1. Hold barbell in front of thighs. 2. Push hips back, lowering bar along legs. 3. Keep slight knee bend. 4. Feel stretch in hamstrings. 5. Drive hips forward to stand.', '/videos/rdl.mp4', '/images/rdl.jpg', 8, false, 'FREE_WEIGHTS'),
('Leg Curl', 'An isolation exercise for the hamstrings.', 'BEGINNER', 'ISOLATION', '1. Lie face down on leg curl machine. 2. Position pad just above heels. 3. Curl weight up by bending knees. 4. Squeeze hamstrings at top. 5. Lower with control.', '/videos/leg-curl.mp4', '/images/leg-curl.jpg', 4, false, 'MACHINE'),
('Leg Extension', 'An isolation exercise for the quadriceps.', 'BEGINNER', 'ISOLATION', '1. Sit on leg extension machine. 2. Position pad on lower shins. 3. Extend legs to straighten. 4. Squeeze quads at top. 5. Lower with control.', '/videos/leg-extension.mp4', '/images/leg-extension.jpg', 4, false, 'MACHINE'),
('Lunges', 'A unilateral leg exercise for building strength and balance.', 'BEGINNER', 'COMPOUND', '1. Stand with feet together. 2. Step forward into a lunge. 3. Lower until both knees are at 90 degrees. 4. Push through front foot to stand. 5. Alternate legs.', '/videos/lunges.mp4', '/images/lunges.jpg', 7, false, 'BODYWEIGHT'),
('Bulgarian Split Squat', 'A challenging unilateral exercise for leg development and stability.', 'INTERMEDIATE', 'COMPOUND', '1. Stand in front of bench, place rear foot on it. 2. Lower until front thigh is parallel to floor. 3. Keep torso upright. 4. Drive through front heel to stand. 5. Keep knee tracking over toe.', '/videos/bulgarian-split.mp4', '/images/bulgarian-split.jpg', 8, false, 'BODYWEIGHT'),
('Calf Raises', 'An isolation exercise for the calf muscles.', 'BEGINNER', 'ISOLATION', '1. Stand on edge of step with heels hanging off. 2. Rise up on toes as high as possible. 3. Hold briefly at top. 4. Lower heels below step level. 5. Feel full stretch at bottom.', '/videos/calf-raises.mp4', '/images/calf-raises.jpg', 4, false, 'BODYWEIGHT'),
('Hack Squat', 'A machine squat variation for targeting the quadriceps with back support.', 'INTERMEDIATE', 'COMPOUND', '1. Position shoulders under pads of hack squat. 2. Place feet shoulder-width on platform. 3. Lower weight by bending knees. 4. Go until thighs are parallel. 5. Press back up through heels.', '/videos/hack-squat.mp4', '/images/hack-squat.jpg', 8, false, 'MACHINE'),
('Hip Thrust', 'An exercise specifically targeting the glutes for building strength and size.', 'INTERMEDIATE', 'COMPOUND', '1. Sit with upper back against bench, barbell over hips. 2. Plant feet flat on floor. 3. Drive hips up by squeezing glutes. 4. Hold briefly at top. 5. Lower with control.', '/videos/hip-thrust.mp4', '/images/hip-thrust.jpg', 7, false, 'FREE_WEIGHTS'),

-- CORE EXERCISES
('Plank', 'An isometric core exercise for building overall core stability and endurance.', 'BEGINNER', 'ISOLATION', '1. Position forearms on floor, elbows under shoulders. 2. Extend legs back, toes on floor. 3. Keep body in straight line. 4. Engage core and hold position. 5. Breathe normally throughout.', '/videos/plank.mp4', '/images/plank.jpg', 4, false, 'BODYWEIGHT'),
('Crunches', 'A basic abdominal exercise for targeting the rectus abdominis.', 'BEGINNER', 'ISOLATION', '1. Lie on back, knees bent, feet flat. 2. Place hands behind head or across chest. 3. Curl shoulders off floor. 4. Squeeze abs at top. 5. Lower with control.', '/videos/crunches.mp4', '/images/crunches.jpg', 5, false, 'BODYWEIGHT'),
('Russian Twist', 'A rotational core exercise targeting the obliques.', 'BEGINNER', 'ISOLATION', '1. Sit with knees bent, feet off floor. 2. Lean back slightly, holding weight at chest. 3. Rotate torso to one side. 4. Touch weight to floor. 5. Rotate to other side.', '/videos/russian-twist.mp4', '/images/russian-twist.jpg', 5, false, 'BODYWEIGHT'),
('Hanging Leg Raise', 'An advanced core exercise targeting the lower abs.', 'ADVANCED', 'ISOLATION', '1. Hang from pull-up bar with arms straight. 2. Keep legs straight or slightly bent. 3. Raise legs to parallel or higher. 4. Lower with control. 5. Avoid swinging.', '/videos/hanging-leg-raise.mp4', '/images/hanging-leg-raise.jpg', 6, false, 'BODYWEIGHT'),
('Cable Woodchop', 'A rotational core exercise that mimics functional movements.', 'INTERMEDIATE', 'COMPOUND', '1. Stand sideways to cable machine. 2. Set cable high, grip handle with both hands. 3. Pull diagonally across body. 4. Rotate through core. 5. Control return movement.', '/videos/cable-woodchop.mp4', '/images/cable-woodchop.jpg', 5, false, 'MACHINE'),
('Ab Rollout', 'An advanced core exercise for building anti-extension strength.', 'ADVANCED', 'ISOLATION', '1. Kneel on floor holding ab roller. 2. Roll forward, extending body. 3. Go as far as you can control. 4. Contract abs to roll back. 5. Keep hips from sagging.', '/videos/ab-rollout.mp4', '/images/ab-rollout.jpg', 6, false, 'ACCESSORIES'),
('Dead Bug', 'A core stability exercise excellent for beginners and rehabilitation.', 'BEGINNER', 'ISOLATION', '1. Lie on back, arms extended to ceiling. 2. Lift legs with knees at 90 degrees. 3. Lower opposite arm and leg. 4. Keep lower back pressed to floor. 5. Return and alternate sides.', '/videos/dead-bug.mp4', '/images/dead-bug.jpg', 3, false, 'BODYWEIGHT'),
('Mountain Climbers', 'A dynamic core exercise that also elevates heart rate.', 'BEGINNER', 'COMPOUND', '1. Start in push-up position. 2. Drive one knee towards chest. 3. Quickly switch legs. 4. Continue alternating at rapid pace. 5. Keep hips level throughout.', '/videos/mountain-climbers.mp4', '/images/mountain-climbers.jpg', 10, false, 'BODYWEIGHT');

-- =====================================================
-- 6. EXERCISE-MUSCLE GROUP RELATIONSHIPS
-- =====================================================
-- Chest Exercises
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

-- =====================================================
-- 7. EXERCISE-EQUIPMENT RELATIONSHIPS
-- =====================================================
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
-- 10. MEAL TEMPLATES
-- Note: Meal templates require a nutrition_plan to exist first (which is user-specific).
--       The insert_meal_templates.sql file contains the template data that can be
--       run manually after creating a nutrition plan, or meal templates are created
--       programmatically when a user's nutrition plan is generated.
-- =====================================================
