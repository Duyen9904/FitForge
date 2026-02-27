
FitForge - Personalized Gym Workout Builder

Complete Use Case Catalog
1. USER MANAGEMENT
   UC-1.1: User Registration
   Actor: New User
   Description: User creates an account with personal information and fitness profile
   Preconditions: None
   Flow:
   User provides username, email, password, date of birth, gender, height, current weight, target weight
   System validates unique email/username
   System creates user account with default preferences
   System sends welcome email
   User is redirected to onboarding
   Postconditions: User account created, user can log in
   UC-1.2: User Login
   Actor: Registered User
   Description: User authenticates to access the system
   Preconditions: User must have an account
   Flow:
   User enters email and password
   System validates credentials
   System generates JWT token
   User is redirected to dashboard
   Postconditions: User is authenticated and can access protected resources
   UC-1.3: Update User Profile
   Actor: Authenticated User
   Description: User updates personal information and profile settings
   Preconditions: User must be logged in
   Flow:
   User navigates to profile settings
   User updates information (weight, height, fitness level, profile image)
   System validates and saves changes
   System displays confirmation message
   Postconditions: User profile is updated
   UC-1.4: Manage User Preferences
   Actor: Authenticated User
   Description: User configures workout and notification preferences
   Preconditions: User must be logged in
   Flow:
   User navigates to preferences
   User sets preferred workout duration, workout time, notification settings, measurement units, reminder days
   User enables/disables AI suggestions
   System saves preferences
   Postconditions: User preferences are updated and applied to future interactions

2. WORKOUT PLAN MANAGEMENT
   UC-2.1: Create Manual Workout Plan
   Actor: Authenticated User
   Description: User manually creates a customized workout plan
   Preconditions: User must be logged in
   Flow:
   User clicks "Create New Plan"
   User enters plan details:
   Plan name and description
   Fitness goal (muscle gain, fat loss, strength, endurance)
   Target muscle groups (back, chest, arms, legs, glutes, full body)
   Frequency per week (1-7 days)
   Duration in weeks (1-52)
   Difficulty level (beginner, intermediate, advanced)
   User adds workout sessions (days)
   For each session, user selects exercises
   For each exercise, user sets sets, reps, weight, rest time
   System validates plan structure
   System saves workout plan
   Postconditions: Workout plan is created and active
   UC-2.2: Generate AI-Powered Workout Plan
   Actor: Authenticated User
   Description: User generates a workout plan using AI recommendations
   Preconditions: User must be logged in
   Flow:
   User clicks "Generate AI Plan"
   User selects fitness goal and preferences
   System analyzes user profile (fitness level, equipment access, time availability)
   AI generates optimized workout plan with:
   Appropriate exercise selection
   Progressive overload structure
   Balanced muscle group distribution
   Suitable volume and intensity
   User reviews generated plan
   User can accept, modify, or regenerate
   Postconditions: AI-generated workout plan is created
   UC-2.3: Edit Workout Plan
   Actor: Authenticated User
   Description: User modifies existing workout plan
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan to edit
   User modifies plan details, sessions, or exercises
   System validates changes
   System updates plan with new timestamp
   Postconditions: Workout plan is updated
   UC-2.4: View Workout Plan Details
   Actor: Authenticated User
   Description: User views complete details of a workout plan
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan
   System displays plan overview with all sessions and exercises
   User can view exercise details (instructions, videos, muscle groups)
   Postconditions: User has viewed plan details
   UC-2.5: Activate/Deactivate Workout Plan
   Actor: Authenticated User
   Description: User toggles workout plan active status
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan
   User clicks activate/deactivate
   System updates plan status
   Postconditions: Plan status is changed
   UC-2.6: Delete Workout Plan
   Actor: Authenticated User
   Description: User permanently removes a workout plan
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan to delete
   System shows confirmation dialog
   User confirms deletion
   System removes plan and all associated data
   Postconditions: Workout plan is deleted
   UC-2.7: Duplicate Workout Plan
   Actor: Authenticated User
   Description: User creates a copy of existing workout plan
   Preconditions: User must own or have access to the workout plan
   Flow:
   User selects workout plan to duplicate
   User clicks "Duplicate"
   System creates copy with new name
   User can modify duplicated plan
   Postconditions: New workout plan created as copy

3. WORKOUT SESSION MANAGEMENT
   UC-3.1: Create Workout Session
   Actor: Authenticated User
   Description: User adds a workout session (day) to a plan
   Preconditions: Workout plan must exist
   Flow:
   User opens workout plan
   User clicks "Add Session"
   User enters session details:
   Session name (e.g., "Upper Body Day 1")
   Day number
   Focus area (chest, back, legs, etc.)
   Warm-up notes
   Cool-down notes
   System adds session to plan
   Postconditions: Workout session is created
   UC-3.2: Add Exercises to Session
   Actor: Authenticated User
   Description: User adds exercises to a workout session
   Preconditions: Workout session must exist
   Flow:
   User opens workout session
   User clicks "Add Exercise"
   User searches/browses exercise library
   User selects exercise
   User configures:
   Sets (1-10)
   Repetitions (1-100)
   Weight (kg)
   Rest time (seconds)
   Order/sequence
   Superset flag
   Personal notes
   System adds exercise to session
   Postconditions: Exercise is added to session
   UC-3.3: Reorder Exercises in Session
   Actor: Authenticated User
   Description: User changes exercise order within a session
   Preconditions: Session must have multiple exercises
   Flow:
   User opens workout session
   User drags and drops exercises to reorder
   System updates exercise sequence
   Postconditions: Exercise order is updated
   UC-3.4: Remove Exercise from Session
   Actor: Authenticated User
   Description: User removes an exercise from a session
   Preconditions: Exercise must be in session
   Flow:
   User opens workout session
   User clicks delete on exercise
   System removes exercise from session
   Postconditions: Exercise is removed

4. EXERCISE LIBRARY MANAGEMENT
   UC-4.1: Browse Exercise Library
   Actor: Authenticated User, Guest
   Description: User explores available exercises
   Preconditions: User must be logged in
   Flow:
   User navigates to exercise library
   System displays categorized exercises
   User can filter by:
   Muscle group
   Equipment type
   Difficulty level
   Exercise type (compound, isolation)
   User can search by name
   Postconditions: User views filtered exercises
   UC-4.2: View Exercise Details
   Actor: Authenticated User, Guest
   Description: User views comprehensive exercise information
   Preconditions: None
   Flow:
   User selects exercise
   System displays:
   Exercise name and description
   Step-by-step instructions
   Video demonstration
   Target muscle groups (primary and secondary)
   Required equipment
   Difficulty level
   Calories burned per minute
   Safety notes (requires spotter, etc.)
   Alternative exercises
   Postconditions: User has viewed exercise details
   UC-4.3: Add Exercise to Favorites
   Actor: Authenticated User
   Description: User saves frequently used exercises for quick access
   Preconditions: User must be logged in
   Flow:
   User views exercise
   User clicks "Add to Favorites"
   System saves exercise to user's favorites list
   Postconditions: Exercise is in favorites
   UC-4.4: View Alternative Exercises
   Actor: Authenticated User, Guest
   Description: User finds substitute exercises for equipment or injury limitations
   Preconditions: Exercise must have alternatives defined
   Flow:
   User views exercise details
   User clicks "Show Alternatives"
   System displays alternative exercises with reasons:
   Equipment substitution (e.g., dumbbell instead of barbell)
   Difficulty variation (easier/harder version)
   Injury modification (low-impact alternative)
   User can select alternative to replace original
   Postconditions: User views alternatives
   UC-4.5: Create Custom Exercise
   Actor: Admin/Trainer
   Description: Privileged user adds new exercise to library
   Preconditions: User must have admin/trainer role
   Flow:
   User navigates to exercise management
   User clicks "Create Exercise"
   User enters exercise details and uploads media
   User assigns muscle groups and equipment
   System validates and saves exercise
   Postconditions: New exercise is available in library

5. WORKOUT EXECUTION & PROGRESS TRACKING
   UC-5.1: Start Workout Session
   Actor: Authenticated User
   Description: User begins executing a scheduled workout
   Preconditions: User must have active workout plan
   Flow:
   User selects today's workout session
   User clicks "Start Workout"
   System records start time
   System displays first exercise with details
   User follows warm-up instructions
   Postconditions: Workout session is in progress
   UC-5.2: Log Exercise Performance
   Actor: Authenticated User
   Description: User records actual performance for each set
   Preconditions: Workout must be in progress
   Flow:
   System displays current exercise
   For each set, user logs:
   Repetitions completed
   Weight used
   Actual rest time
   Completion status
   Set-specific notes (e.g., "felt easy", "struggled on last rep")
   System validates and saves set data
   System shows next set or exercise
   Postconditions: Exercise performance is logged
   UC-5.3: Complete Workout Session
   Actor: Authenticated User
   Description: User finishes workout and provides session summary
   Preconditions: Workout must be in progress
   Flow:
   User completes all exercises
   User clicks "Finish Workout"
   System calculates:
   Total duration
   Estimated calories burned
   Volume lifted (sets × reps × weight)
   User provides:
   Difficulty rating (1-5)
   Performance notes
   Mood rating
   System saves workout progress record
   Postconditions: Workout is completed and logged
   UC-5.4: Skip Exercise
   Actor: Authenticated User
   Description: User skips an exercise during workout
   Preconditions: Workout must be in progress
   Flow:
   User is on current exercise
   User clicks "Skip Exercise"
   User provides reason (equipment unavailable, injury, fatigue)
   System marks exercise as skipped
   System moves to next exercise
   Postconditions: Exercise is marked as skipped
   UC-5.5: View Workout History
   Actor: Authenticated User
   Description: User reviews past workout sessions
   Preconditions: User must have completed workouts
   Flow:
   User navigates to workout history
   System displays list of completed sessions with:
   Date, duration, calories burned
   Completion status
   Difficulty rating
   User can filter by date range or workout plan
   User clicks on session to view detailed logs
   Postconditions: User views workout history
   UC-5.6: View Progress Charts
   Actor: Authenticated User
   Description: User analyzes workout performance over time
   Preconditions: User must have workout history
   Flow:
   User navigates to progress analytics
   System displays charts:
   Weight lifted progression by exercise
   Volume per muscle group over time
   Workout frequency and consistency
   Calories burned trends
   Strength gains (1RM estimates)
   User can select date ranges and specific exercises
   Postconditions: User views progress visualizations

6. MISSED WORKOUT MANAGEMENT
   UC-6.1: Log Missed Workout
   Actor: Authenticated User
   Description: User reports a skipped workout session
   Preconditions: User has an active workout plan
   Flow:
   User opens scheduled workout
   User clicks "Mark as Missed"
   User provides reason:
   Sick/Injured
   Too busy
   No motivation
   Equipment unavailable
   Other (custom text)
   System records missed workout
   Postconditions: Missed workout is logged
   UC-6.2: Generate Makeup Workout Plan
   Actor: System (Automated)
   Description: System automatically suggests compensation strategies
   Preconditions: User has missed a workout
   Flow:
   System detects missed workout
   System analyzes:
   Missed exercises and muscle groups
   User's remaining schedule
   Plan structure and goals
   System generates compensation actions:
   Option A: Reschedule entire session to next available day
   Option B: Distribute missed exercises across upcoming sessions
   Option C: Add weekend makeup session
   Option D: Extend program by one week
   System presents options to user
   User selects preferred strategy
   System updates workout plan accordingly
   Postconditions: Makeup plan is created
   UC-6.3: Reschedule Missed Workout
   Actor: Authenticated User
   Description: User manually reschedules a missed session
   Preconditions: Missed workout exists
   Flow:
   User views missed workouts
   User selects missed session
   User chooses new date/time
   System checks for scheduling conflicts
   System reschedules workout
   Postconditions: Workout is rescheduled
   UC-6.4: View Missed Workout Report
   Actor: Authenticated User
   Description: User reviews consistency metrics
   Preconditions: User has workout history
   Flow:
   User navigates to consistency report
   System displays:
   Total missed workouts
   Missed workout patterns (days of week, reasons)
   Compensation completion rate
   Adherence percentage
   Recommendations for improvement
   Postconditions: User views missed workout analytics

7. NUTRITION MANAGEMENT
   UC-7.1: Create Nutrition Plan
   Actor: Authenticated User
   Description: User sets up personalized meal plan
   Preconditions: User must be logged in
   Flow:
   User navigates to nutrition planning
   User enters:
   Plan name
   Linked fitness goal
   Daily calorie target
   Macronutrient distribution (protein %, carbs %, fats %)
   Allowed cheat meals per week
   User enables auto-adjustment feature
   System calculates macro targets in grams
   System saves nutrition plan
   Postconditions: Nutrition plan is created and active
   UC-7.2: Log Daily Meals
   Actor: Authenticated User
   Description: User records food intake
   Preconditions: User must be logged in
   Flow:
   User clicks "Log Meal"
   User enters:
   Meal type (breakfast, lunch, dinner, snack)
   Food name/description
   Calories
   Protein, carbs, fats (grams)
   Meal time
   Cheat meal flag (yes/no)
   Notes
   System calculates running daily totals
   System saves nutrition log
   Postconditions: Meal is logged, daily totals updated
   UC-7.3: Log Cheat Meal
   Actor: Authenticated User
   Description: User records dietary deviation
   Preconditions: User must have active nutrition plan
   Flow:
   User logs meal as normal
   User checks "This is a cheat meal"
   System calculates excess calories (vs. planned meal)
   System triggers compensation action generation
   System creates cheat meal log with:
   Excess calories
   Date
   Planned compensation strategy
   Postconditions: Cheat meal is logged, compensation triggered
   UC-7.4: Generate Cheat Meal Compensation Plan
   Actor: System (Automated)
   Description: System suggests actions to compensate for cheat meal
   Preconditions: Cheat meal has been logged
   Flow:
   System calculates excess calories (e.g., 800 calories over target)
   System generates compensation options:
   Option A: Add 30-minute cardio to next 2 workouts (burn ~400 cal)
   Option B: Reduce daily calories by 200 for next 4 days
   Option C: Combination: add 20-min cardio + reduce 100 cal/day for 3 days
   Option D: Do nothing, accept the deviation
   System presents options with explanations
   User selects preferred strategy
   System creates compensation action and adjusts plans
   Postconditions: Compensation plan is active
   UC-7.5: View Nutrition Dashboard
   Actor: Authenticated User
   Description: User monitors daily nutrition status
   Preconditions: User has logged meals
   Flow:
   User navigates to nutrition dashboard
   System displays:
   Today's calorie and macro progress (vs. targets)
   Remaining calories/macros for the day
   Recent meal logs
   Weekly cheat meal count (vs. allowed)
   Active compensation plans
   Nutritional trends (7-day, 30-day)
   Postconditions: User views nutrition status
   UC-7.6: Create Meal Template
   Actor: Authenticated User
   Description: User saves frequently eaten meals for quick logging
   Preconditions: User must have nutrition plan
   Flow:
   User navigates to meal templates
   User clicks "Create Template"
   User enters:
   Meal name
   Meal type
   Ingredients and nutritional values
   Recipe instructions
   System saves template
   Postconditions: Meal template is created
   UC-7.7: Use Meal Template
   Actor: Authenticated User
   Description: User quickly logs meal from saved template
   Preconditions: Meal templates must exist
   Flow:
   User clicks "Log Meal"
   User selects "Use Template"
   User chooses template from list
   System auto-fills meal details
   User can adjust quantities if needed
   System logs meal
   Postconditions: Meal is logged from template

8. BODY MEASUREMENT TRACKING
   UC-8.1: Record Body Measurements
   Actor: Authenticated User
   Description: User logs physical measurements
   Preconditions: User must be logged in
   Flow:
   User navigates to measurements
   User clicks "Add Measurement"
   User enters:
   Measurement date
   Weight (kg)
   Body fat percentage
   Chest, waist, hips, biceps, thighs (cm)
   Optional notes
   System validates data
   System saves measurement record
   Postconditions: Measurement is recorded
   UC-8.2: View Measurement History
   Actor: Authenticated User
   Description: User reviews measurement trends
   Preconditions: User must have measurement history
   Flow:
   User navigates to measurement history
   System displays:
   Table of all measurements with dates
   Line charts showing trends for each metric
   Progress indicators (gained/lost)
   Comparison to target weight
   User can select date range
   Postconditions: User views measurement trends
   UC-8.3: Set Measurement Goals
   Actor: Authenticated User
   Description: User defines target measurements
   Preconditions: User must be logged in
   Flow:
   User navigates to measurement goals
   User sets targets for:
   Target weight
   Target body fat percentage
   Target measurements
   Target date
   System saves goals and calculates required weekly changes
   Postconditions: Measurement goals are set
   UC-8.4: View Progress Photos
   Actor: Authenticated User
   Description: User uploads and compares transformation photos
   Preconditions: User must be logged in
   Flow:
   User navigates to progress photos
   User uploads photo with date
   System organizes photos chronologically
   User can view side-by-side comparisons
   Postconditions: Progress photo is uploaded

9. RECOVERY & WELLNESS TRACKING
   UC-9.1: Log Daily Recovery Metrics
   Actor: Authenticated User
   Description: User records recovery and wellness indicators
   Preconditions: User must be logged in
   Flow:
   User navigates to recovery tracker
   User logs:
   Sleep hours (0-12)
   Sleep quality rating (1-5)
   Stress level (1-5)
   Muscle soreness level (1-5)
   Energy level (1-5)
   Optional notes
   System saves recovery record
   Postconditions: Recovery metrics are logged
   UC-9.2: View Recovery Dashboard
   Actor: Authenticated User
   Description: User monitors recovery trends
   Preconditions: User has recovery history
   Flow:
   User navigates to recovery dashboard
   System displays:
   Average sleep duration (weekly)
   Sleep quality trends
   Stress level patterns
   Soreness by muscle group
   Energy level correlation with workout performance
   Recovery recommendations
   Postconditions: User views recovery analytics
   UC-9.3: Receive Recovery Alerts
   Actor: System (Automated)
   Description: System warns user of potential overtraining
   Preconditions: User has consistent recovery tracking
   Flow:
   System analyzes recovery patterns
   System detects warning signs:
   Sleep debt accumulating (< 6 hours for 3+ days)
   High stress sustained (4-5/5 for 5+ days)
   Persistent soreness (4-5/5 for 7+ days)
   Declining workout performance
   System generates alert with recommendations:
   Take rest day
   Reduce workout intensity
   Add stretching/mobility work
   Consult healthcare provider
   Postconditions: User receives recovery alert

10. ACHIEVEMENT & GAMIFICATION
    UC-10.1: Earn Achievement
    Actor: System (Automated)
    Description: System awards badge when criteria is met
    Preconditions: Achievement criteria defined
    Flow:
    System monitors user activities
    System detects achievement criteria met:
    "First Workout" - Complete first session
    "7-Day Streak" - Workout 7 consecutive days
    "Century Club" - Complete 100 workouts
    "Iron Pumper" - Lift 10,000 kg total volume
    "Consistency King" - 80%+ adherence for 8 weeks
    "Transformation" - Lose/gain target weight
    "Nutrition Ninja" - Track meals for 30 days
    System awards achievement and points
    System displays notification to user
    Postconditions: Achievement is earned and displayed
    UC-10.2: View Achievement Gallery
    Actor: Authenticated User
    Description: User reviews earned achievements
    Preconditions: User must be logged in
    Flow:
    User navigates to achievements
    System displays:
    All earned achievements with dates
    Locked achievements (not yet earned)
    Progress toward locked achievements
    Total points earned
    Leaderboard ranking (optional)
    Postconditions: User views achievements
    UC-10.3: Share Achievement
    Actor: Authenticated User
    Description: User shares accomplishment
    Preconditions: Achievement must be earned
    Flow:
    User selects achievement
    User clicks "Share"
    System generates shareable image/link
    User can share on social media or copy link
    Postconditions: Achievement is shared

11. COMPENSATION & ADAPTATION SYSTEM
    UC-11.1: Trigger Compensation Action
    Actor: System (Automated)
    Description: System creates adaptive response to user deviation
    Preconditions: User has logged cheat meal OR missed workout
    Flow:
    System detects triggering event:
    Cheat meal with excess calories
    Missed workout session
    System analyzes:
    Current workout plan structure
    Current nutrition plan
    User preferences (allow auto-adjust)
    Historical adherence patterns
    System generates compensation action with:
    Action type (add cardio, reduce calories, reschedule workout)
    Action description
    Scheduled date
    Calorie adjustment amount
    Detailed implementation plan
    System links action to both workout and nutrition plans
    Postconditions: Compensation action is created and pending
    UC-11.2: Review Compensation Options
    Actor: Authenticated User
    Description: User reviews and selects compensation strategy
    Preconditions: Compensation action has been triggered
    Flow:
    User receives notification of compensation action
    User navigates to compensation dashboard
    System displays:
    Triggering event details
    Multiple compensation options
    Expected impact of each option
    Recommendation based on user goals
    User selects preferred option
    System activates selected compensation
    Postconditions: Compensation action is activated
    UC-11.3: Apply Nutrition Adjustment
    Actor: System (Automated)
    Description: System temporarily modifies nutrition targets
    Preconditions: Compensation action selected
    Flow:
    System creates nutrition adjustment record
    System modifies daily targets:
    Reduce calories by specified amount
    Adjust macro distribution if needed
    Set valid date range (e.g., next 3-5 days)
    System displays adjusted targets on nutrition dashboard
    System tracks user adherence to adjustment
    After valid period, system restores original targets
    Postconditions: Nutrition targets temporarily adjusted
    UC-11.4: Apply Workout Adjustment
    Actor: System (Automated)
    Description: System modifies workout schedule or content
    Preconditions: Compensation action selected
    Flow:
    System creates makeup workout record
    System applies selected strategy:
    Reschedule: Move entire session to new date
    Distribute: Add missed exercises to existing sessions
    Add Session: Create new workout day
    Extend Program: Push end date by one week
    System updates workout plan schedule
    System notifies user of changes
    User sees updated schedule
    Postconditions: Workout plan adjusted
    UC-11.5: Complete Compensation Action
    Actor: Authenticated User
    Description: User fulfills compensation requirement
    Preconditions: Compensation action is active
    Flow:
    User completes required action:
    Finishes added cardio session
    Adheres to reduced calorie targets
    Completes makeup workout
    System detects completion
    System marks compensation as fulfilled
    System updates user stats and adherence metrics
    Postconditions: Compensation action completed
    UC-11.6: View Compensation History
    Actor: Authenticated User
    Description: User reviews past adaptations
    Preconditions: User has compensation history
    Flow:
    User navigates to compensation history
    System displays:
    List of all compensation events
    Triggering causes
    Selected strategies
    Completion status
    Effectiveness metrics
    User can filter by type or date range
    Postconditions: User views compensation history

12. GOAL & RECOMMENDATION MANAGEMENT
    UC-12.1: Browse Fitness Goals
    Actor: Authenticated User
    Description: User views available fitness goal templates
    Preconditions: None
    Flow:
    User navigates to goals library
    System displays predefined goals:
    Muscle Gain: High volume, moderate reps (8-12), 60-90s rest
    Fat Loss: Moderate volume, higher reps (12-15), 30-60s rest
    Strength: Low reps (3-6), heavy weight, 2-3min rest
    Endurance: High reps (15+), low rest (< 30s)
    General Fitness: Balanced approach
    Each goal includes:
    Description
    Recommended training frequency
    Typical workout structure
    Calorie adjustment recommendations
    Postconditions: User views goal details
    UC-12.2: Set Primary Fitness Goal
    Actor: Authenticated User
    Description: User selects main training objective
    Preconditions: User must be logged in
    Flow:
    User selects fitness goal
    System updates user profile
    System adjusts recommendations based on goal:
    Exercise suggestions
    Rep/set schemes
    Nutrition targets
    Rest day frequency
    Postconditions: Primary goal is set
    UC-12.3: Receive Exercise Recommendations
    Actor: System (Automated)
    Description: System suggests exercises based on user context
    Preconditions: User is creating/editing workout plan
    Flow:
    User is adding exercise to session
    System analyzes:
    Current session's exercises
    Muscle groups already targeted
    User's fitness goal
    User's fitness level
    Available equipment
    Historical preferences
    System recommends 5-10 exercises with rationale:
    "Complement chest press with rows for balance"
    "Add leg curls to target hamstrings"
    "Include core work for stability"
    User can select from recommendations
    **

13. REPORTING & ANALYTICS
    UC-13.1: Generate Workout Summary Report
    Actor: Authenticated User
    Description: User creates comprehensive workout performance report
    Preconditions: User has workout history
    Flow:
    User navigates to reports
    User selects "Workout Summary Report"
    User chooses date range (weekly, monthly, custom)
    System generates report with:
    Total workouts completed
    Total duration and calories burned
    Adherence percentage
    Volume lifted by muscle group
    Most improved exercises
    Missed workout analysis
    Recommended adjustments
    User can export as PDF or share
    Postconditions: Report is generated
    UC-13.2: Generate Nutrition Report
    Actor: Authenticated User
    Description: User creates dietary analysis report
    Preconditions: User has nutrition logs
    Flow:
    User navigates to reports
    User selects "Nutrition Report"
    User chooses date range
    System generates report with:
    Average daily calories and macros
    Adherence to targets (%)
    Cheat meal frequency
    Calorie surplus/deficit trends
    Macro distribution analysis
    Recommendations for improvement
    User can export report
    Postconditions: Nutrition report is generated
    UC-13.3: View Body Transformation Report
    Actor: Authenticated User
    Description: User reviews overall physical progress
    Preconditions: User has measurement history
    Flow:
    User navigates to transformation report
    System generates comprehensive view:
    Before/after measurements comparison
    Weight change chart
    Body composition changes
    Progress photos side-by-side
    Achievement timeline
    Workout volume correlation
    Nutrition adherence correlation
    System highlights milestones and improvements
    Postconditions: Transformation report is displayed
    UC-13.4: Export Data
    Actor: Authenticated User
    Description: User exports personal fitness data
    Preconditions: User must be logged in
    Flow:
    User navigates to data export
    User selects data types to export:
    Workout history
    Exercise logs
    Nutrition logs
    Measurements
    Progress photos
    User selects format (CSV, JSON, PDF)
    System packages data
    User downloads export file
    Postconditions: Data is exported

14. SEARCH & FILTERING
    UC-14.1: Search Exercises
    Actor: Authenticated User
    Description: User finds exercises using various criteria
    Preconditions: None
    Flow:
    User enters search query in exercise library
    System searches by:
    Exercise name
    Muscle group
    Equipment type
    Exercise type
    User applies filters:
    Difficulty level
    Requires spotter (yes/no)
    Favorites only
    Recently used
    System displays filtered results
    User can sort by name, difficulty, or popularity
    Postconditions: Filtered exercise list displayed
    UC-14.2: Filter Workout Plans
    Actor: Authenticated User
    Description: User finds specific workout plans
    Preconditions: User has multiple workout plans
    Flow:
    User navigates to workout plans
    User applies filters:
    Active/Inactive status
    Fitness goal
    Target muscle group
    AI-generated vs. manual
    Date created range
    System displays filtered plans
    User can sort by date or name
    Postconditions: Filtered plan list displayed

15. NOTIFICATIONS & REMINDERS
    UC-15.1: Receive Workout Reminder
    Actor: System (Automated)
    Description: System reminds user of scheduled workout
    Preconditions: User has enabled notifications and has active plan
    Flow:
    System checks user's workout schedule
    System detects upcoming workout (based on user preference: 1hr, 3hrs, or morning)
    System sends notification:
    "Time for your Upper Body workout!"
    Session details preview
    Quick start button
    User can snooze, dismiss, or start workout
    Postconditions: User is reminded of workout
    UC-15.2: Receive Streak Notification
    Actor: System (Automated)
    Description: System celebrates workout consistency
    Preconditions: User has workout streak
    Flow:
    System detects user has completed workouts on consecutive days
    System sends motivational notification:
    "🔥 5-day workout streak! Keep it up!"
    Current streak count
    Next achievement milestone
    User receives notification
    Postconditions: User is motivated by streak notification
    UC-15.3: Receive Goal Progress Update
    Actor: System (Automated)
    Description: System notifies user of milestone progress
    Preconditions: User has set goals
    Flow:
    System monitors goal progress
    System detects significant milestone:
    25%, 50%, 75%, 100% of goal achieved
    System sends notification:
    "You've lost 5kg - halfway to your goal!"
    Progress visualization
    Encouragement message
    User views progress details
    Postconditions: User is informed of progress
    UC-15.4: Receive Recovery Alert
    Actor: System (Automated)
    Description: System warns about inadequate recovery
    Preconditions: User tracks recovery metrics
    Flow:
    System analyzes recovery data
    System detects concerning patterns
    System sends alert:
    "Consider taking a rest day - recovery metrics are low"
    Specific metrics of concern
    Recommendations
    User can view details or schedule rest day
    Postconditions: User receives recovery alert

16. SYSTEM ADMINISTRATION (Admin/Trainer Role)
    UC-16.1: Manage Exercise Library
    Actor: Admin/Trainer
    Description: Privileged user manages exercise database
    Preconditions: User must have admin/trainer role
    Flow:
    Admin navigates to exercise management
    Admin can:
    Create new exercises
    Edit existing exercises
    Delete exercises (if not in use)
    Upload/update videos and images
    Define muscle group mappings
    Set equipment requirements
    Add alternative exercises
    System validates and saves changes
    Postconditions: Exercise library is updated
    UC-16.2: Manage Goals Library
    Actor: Admin
    Description: Admin configures fitness goal templates
    Preconditions: User must have admin role
    Flow:
    Admin navigates to goal management
    Admin can:
    Create new goal templates
    Edit goal parameters
    Delete goals (if not in use)
    Set recommended training protocols
    System saves changes
    Postconditions: Goals library is updated
    UC-16.3: View User Analytics (Aggregate)
    Actor: Admin
    Description: Admin reviews system-wide usage statistics
    Preconditions: User must have admin role
    Flow:
    Admin navigates to analytics dashboard
    System displays aggregate data:
    Total active users
    Average workouts per user
    Most popular exercises
    Most popular workout goals
    Average adherence rates
    Cheat meal frequency trends
    Missed workout patterns
    Feature usage statistics
    Admin can export reports
    Postconditions: Admin views system analytics

System Features Summary
Core Features
User Management - Registration, authentication, profile management, preferences
Workout Plan Builder - Manual creation and AI-powered generation
Exercise Library - 200+ exercises with videos, instructions, alternatives
Workout Execution - Real-time logging, set tracking, performance recording
Progress Tracking - Workout history, performance analytics, strength progression
Missed Workout Management - Automatic compensation planning and rescheduling
Nutrition Tracking - Meal logging, macro tracking, nutrition plans
Cheat Meal Compensation - Automatic calorie balancing strategies
Body Measurements - Weight, body composition, circumference tracking
Recovery Monitoring - Sleep, stress, soreness, energy tracking
Achievement System - Gamification with badges and milestones
Intelligent Adaptation - Dynamic plan adjustments based on user behavior
Reporting & Analytics - Comprehensive progress reports and data visualization
Notifications - Workout reminders, streak notifications, goal updates
Unique Differentiators
Intelligent Replanning: Unlike competitors, FitForge automatically adapts plans when users miss workouts
Nutrition-Fitness Integration: Coordinated compensation between workout and nutrition plans
Exercise Alternatives: Built-in substitute suggestions for equipment/injury limitations
Recovery-Aware: System monitors recovery metrics to prevent overtraining
AI + Manual Flexibility: Users can start with AI and customize afterwards
Holistic Approach: Combines workouts, nutrition, measurements, and wellness in one system
Technology Highlights
Spring Boot 3.x backend with modern Java practices
3-Layer Architecture for maintainability and scalability
BaseMapper Pattern for consistent DTO transformations
JWT Authentication for secure API access
RESTful API Design with OpenAPI documentation
JPA/Hibernate for robust data persistence
Responsive Design for web and mobile access

Success Metrics
User Engagement
Daily Active Users (DAU)
Workout completion rate (target: >75%)
Nutrition logging frequency (target: >80% of days)
Feature adoption rates
User Outcomes
Average weight change toward goals
Strength progression metrics
Workout adherence improvement over time
User retention rate (target: >60% after 3 months)
System Performance
API response times (target: <500ms)
Database query efficiency
User data accuracy and integrity
System uptime (target: 99.5%)

Future Enhancements (Post-MVP)
Social Features - Friend connections, workout sharing, community challenges
Wearable Integration - Sync with Apple Watch, Fitbit, Garmin
Video Coaching - Real-time form checking using AI
Marketplace - Premium plans from certified trainers
Advanced AI - Predictive recommendations based on progress patterns
Voice Commands - Hands-free workout logging
Offline Mode - Continue logging without internet
Multi-language Support - Internationalization
Advanced Analytics - Machine learning insights
Progressive Web App - Native mobile app experience

Conclusion
FitForge represents a comprehensive fitness management solution that goes beyond traditional workout tracking by intelligently adapting to real-world challenges. By combining personalized workout planning, nutrition management, intelligent compensation mechanisms, and holistic progress tracking, FitForge empowers users to achieve their fitness goals while maintaining flexibility and sustainability in their training approach.
The system's unique ability to automatically replan workouts and adjust nutrition targets when users deviate from their plans addresses a critical gap in the fitness app market, where most solutions simply track adherence without providing adaptive solutions. This intelligent adaptation, combined with AI-powered recommendations and comprehensive analytics, makes FitForge a powerful tool for anyone serious about improving their fitness journey.FitForge** is an intelligent fitness management system designed to empower users in creating, managing, and adapting personalized workout plans based on their individual fitness goals, target muscle groups, and lifestyle constraints. Unlike traditional fitness applications that offer rigid, one-size-fits-all routines, FitForge provides a flexible, user-centered approach that adapts to real-world challenges such as missed workouts, dietary deviations, and equipment limitations.
Core Value Proposition
FitForge addresses the limitations of existing fitness applications by offering:
Deep Personalization: Customizable workout parameters including exercise selection, sets, repetitions, rest time, and workout frequency
Intelligent Adaptation: Automatic replanning when users miss workouts or have cheat meals
AI-Powered Recommendations: Machine learning-driven workout plan generation based on user goals and preferences
Holistic Health Tracking: Integration of nutrition management, body measurements, and recovery monitoring
Exercise Flexibility: Alternative exercise suggestions for equipment limitations or injury modifications
Technical Architecture
Technology Stack
Backend: Spring Boot 3.x with Java 17+
Database: MySQL/PostgreSQL with JPA/Hibernate
Architecture: 3-Layer Architecture (Controller → Service → Repository)
API Design: RESTful APIs with OpenAPI/Swagger documentation
Security: JWT-based authentication and authorization
Design Patterns:
Repository Pattern for data access
Service Layer for business logic
DTO Pattern with BaseMapper for object transformation
Dependency Injection for loose coupling
Database Design
20 Tables covering users, workouts, exercises, nutrition, progress tracking, and compensation mechanisms
Normalized Schema with proper relationships (One-to-Many, Many-to-Many)
Code-First Approach using JPA entities with automatic schema generation

Complete Use Case Catalog
1. USER MANAGEMENT
   UC-1.1: User Registration
   Actor: New User
   Description: User creates an account with personal information and fitness profile
   Preconditions: None
   Flow:
   User provides username, email, password, date of birth, gender, height, current weight, target weight
   System validates unique email/username
   System creates user account with default preferences
   System sends welcome email
   User is redirected to onboarding
   Postconditions: User account created, user can log in
   UC-1.2: User Login
   Actor: Registered User
   Description: User authenticates to access the system
   Preconditions: User must have an account
   Flow:
   User enters email and password
   System validates credentials
   System generates JWT token
   User is redirected to dashboard
   Postconditions: User is authenticated and can access protected resources
   UC-1.3: Update User Profile
   Actor: Authenticated User
   Description: User updates personal information and profile settings
   Preconditions: User must be logged in
   Flow:
   User navigates to profile settings
   User updates information (weight, height, fitness level, profile image)
   System validates and saves changes
   System displays confirmation message
   Postconditions: User profile is updated
   UC-1.4: Manage User Preferences
   Actor: Authenticated User
   Description: User configures workout and notification preferences
   Preconditions: User must be logged in
   Flow:
   User navigates to preferences
   User sets preferred workout duration, workout time, notification settings, measurement units, reminder days
   User enables/disables AI suggestions
   System saves preferences
   Postconditions: User preferences are updated and applied to future interactions

2. WORKOUT PLAN MANAGEMENT
   UC-2.1: Create Manual Workout Plan
   Actor: Authenticated User
   Description: User manually creates a customized workout plan
   Preconditions: User must be logged in
   Flow:
   User clicks "Create New Plan"
   User enters plan details:
   Plan name and description
   Fitness goal (muscle gain, fat loss, strength, endurance)
   Target muscle groups (back, chest, arms, legs, glutes, full body)
   Frequency per week (1-7 days)
   Duration in weeks (1-52)
   Difficulty level (beginner, intermediate, advanced)
   User adds workout sessions (days)
   For each session, user selects exercises
   For each exercise, user sets sets, reps, weight, rest time
   System validates plan structure
   System saves workout plan
   Postconditions: Workout plan is created and active
   UC-2.2: Generate AI-Powered Workout Plan
   Actor: Authenticated User
   Description: User generates a workout plan using AI recommendations
   Preconditions: User must be logged in
   Flow:
   User clicks "Generate AI Plan"
   User selects fitness goal and preferences
   System analyzes user profile (fitness level, equipment access, time availability)
   AI generates optimized workout plan with:
   Appropriate exercise selection
   Progressive overload structure
   Balanced muscle group distribution
   Suitable volume and intensity
   User reviews generated plan
   User can accept, modify, or regenerate
   Postconditions: AI-generated workout plan is created
   UC-2.3: Edit Workout Plan
   Actor: Authenticated User
   Description: User modifies existing workout plan
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan to edit
   User modifies plan details, sessions, or exercises
   System validates changes
   System updates plan with new timestamp
   Postconditions: Workout plan is updated
   UC-2.4: View Workout Plan Details
   Actor: Authenticated User
   Description: User views complete details of a workout plan
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan
   System displays plan overview with all sessions and exercises
   User can view exercise details (instructions, videos, muscle groups)
   Postconditions: User has viewed plan details
   UC-2.5: Activate/Deactivate Workout Plan
   Actor: Authenticated User
   Description: User toggles workout plan active status
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan
   User clicks activate/deactivate
   System updates plan status
   Postconditions: Plan status is changed
   UC-2.6: Delete Workout Plan
   Actor: Authenticated User
   Description: User permanently removes a workout plan
   Preconditions: User must own the workout plan
   Flow:
   User selects workout plan to delete
   System shows confirmation dialog
   User confirms deletion
   System removes plan and all associated data
   Postconditions: Workout plan is deleted
   UC-2.7: Duplicate Workout Plan
   Actor: Authenticated User
   Description: User creates a copy of existing workout plan
   Preconditions: User must own or have access to the workout plan
   Flow:
   User selects workout plan to duplicate
   User clicks "Duplicate"
   System creates copy with new name
   User can modify duplicated plan
   Postconditions: New workout plan created as copy

3. WORKOUT SESSION MANAGEMENT
   UC-3.1: Create Workout Session
   Actor: Authenticated User
   Description: User adds a workout session (day) to a plan
   Preconditions: Workout plan must exist
   Flow:
   User opens workout plan
   User clicks "Add Session"
   User enters session details:
   Session name (e.g., "Upper Body Day 1")
   Day number
   Focus area (chest, back, legs, etc.)
   Warm-up notes
   Cool-down notes
   System adds session to plan
   Postconditions: Workout session is created
   UC-3.2: Add Exercises to Session
   Actor: Authenticated User
   Description: User adds exercises to a workout session
   Preconditions: Workout session must exist
   Flow:
   User opens workout session
   User clicks "Add Exercise"
   User searches/browses exercise library
   User selects exercise
   User configures:
   Sets (1-10)
   Repetitions (1-100)
   Weight (kg)
   Rest time (seconds)
   Order/sequence
   Superset flag
   Personal notes
   System adds exercise to session
   Postconditions: Exercise is added to session
   UC-3.3: Reorder Exercises in Session
   Actor: Authenticated User
   Description: User changes exercise order within a session
   Preconditions: Session must have multiple exercises
   Flow:
   User opens workout session
   User drags and drops exercises to reorder
   System updates exercise sequence
   Postconditions: Exercise order is updated
   UC-3.4: Remove Exercise from Session
   Actor: Authenticated User
   Description: User removes an exercise from a session
   Preconditions: Exercise must be in session
   Flow:
   User opens workout session
   User clicks delete on exercise
   System removes exercise from session
   Postconditions: Exercise is removed

4. EXERCISE LIBRARY MANAGEMENT
   UC-4.1: Browse Exercise Library
   Actor: Authenticated User
   Description: User explores available exercises
   Preconditions: User must be logged in
   Flow:
   User navigates to exercise library
   System displays categorized exercises
   User can filter by:
   Muscle group
   Equipment type
   Difficulty level
   Exercise type (compound, isolation)
   User can search by name
   Postconditions: User views filtered exercises
   UC-4.2: View Exercise Details
   Actor: Authenticated User
   Description: User views comprehensive exercise information
   Preconditions: None
   Flow:
   User selects exercise
   System displays:
   Exercise name and description
   Step-by-step instructions
   Video demonstration
   Target muscle groups (primary and secondary)
   Required equipment
   Difficulty level
   Calories burned per minute
   Safety notes (requires spotter, etc.)
   Alternative exercises
   Postconditions: User has viewed exercise details
   UC-4.3: Add Exercise to Favorites
   Actor: Authenticated User
   Description: User saves frequently used exercises for quick access
   Preconditions: User must be logged in
   Flow:
   User views exercise
   User clicks "Add to Favorites"
   System saves exercise to user's favorites list
   Postconditions: Exercise is in favorites
   UC-4.4: View Alternative Exercises
   Actor: Authenticated User
   Description: User finds substitute exercises for equipment or injury limitations
   Preconditions: Exercise must have alternatives defined
   Flow:
   User views exercise details
   User clicks "Show Alternatives"
   System displays alternative exercises with reasons:
   Equipment substitution (e.g., dumbbell instead of barbell)
   Difficulty variation (easier/harder version)
   Injury modification (low-impact alternative)
   User can select alternative to replace original
   Postconditions: User views alternatives
   UC-4.5: Create Custom Exercise
   Actor: Admin/Trainer
   Description: Privileged user adds new exercise to library
   Preconditions: User must have admin/trainer role
   Flow:
   User navigates to exercise management
   User clicks "Create Exercise"
   User enters exercise details and uploads media
   User assigns muscle groups and equipment
   System validates and saves exercise
   Postconditions: New exercise is available in library

5. WORKOUT EXECUTION & PROGRESS TRACKING
   UC-5.1: Start Workout Session
   Actor: Authenticated User
   Description: User begins executing a scheduled workout
   Preconditions: User must have active workout plan
   Flow:
   User selects today's workout session
   User clicks "Start Workout"
   System records start time
   System displays first exercise with details
   User follows warm-up instructions
   Postconditions: Workout session is in progress
   UC-5.2: Log Exercise Performance
   Actor: Authenticated User
   Description: User records actual performance for each set
   Preconditions: Workout must be in progress
   Flow:
   System displays current exercise
   For each set, user logs:
   Repetitions completed
   Weight used
   Actual rest time
   Completion status
   Set-specific notes (e.g., "felt easy", "struggled on last rep")
   System validates and saves set data
   System shows next set or exercise
   Postconditions: Exercise performance is logged
   UC-5.3: Complete Workout Session
   Actor: Authenticated User
   Description: User finishes workout and provides session summary
   Preconditions: Workout must be in progress
   Flow:
   User completes all exercises
   User clicks "Finish Workout"
   System calculates:
   Total duration
   Estimated calories burned
   Volume lifted (sets × reps × weight)
   User provides:
   Difficulty rating (1-5)
   Performance notes
   Mood rating
   System saves workout progress record
   Postconditions: Workout is completed and logged
   UC-5.4: Skip Exercise
   Actor: Authenticated User
   Description: User skips an exercise during workout
   Preconditions: Workout must be in progress
   Flow:
   User is on current exercise
   User clicks "Skip Exercise"
   User provides reason (equipment unavailable, injury, fatigue)
   System marks exercise as skipped
   System moves to next exercise
   Postconditions: Exercise is marked as skipped
   UC-5.5: View Workout History
   Actor: Authenticated User
   Description: User reviews past workout sessions
   Preconditions: User must have completed workouts
   Flow:
   User navigates to workout history
   System displays list of completed sessions with:
   Date, duration, calories burned
   Completion status
   Difficulty rating
   User can filter by date range or workout plan
   User clicks on session to view detailed logs
   Postconditions: User views workout history
   UC-5.6: View Progress Charts
   Actor: Authenticated User
   Description: User analyzes workout performance over time
   Preconditions: User must have workout history
   Flow:
   User navigates to progress analytics
   System displays charts:
   Weight lifted progression by exercise
   Volume per muscle group over time
   Workout frequency and consistency
   Calories burned trends
   Strength gains (1RM estimates)
   User can select date ranges and specific exercises
   Postconditions: User views progress visualizations

6. MISSED WORKOUT MANAGEMENT
   UC-6.1: Log Missed Workout
   Actor: Authenticated User
   Description: User reports a skipped workout session
   Preconditions: User has an active workout plan
   Flow:
   User opens scheduled workout
   User clicks "Mark as Missed"
   User provides reason:
   Sick/Injured
   Too busy
   No motivation
   Equipment unavailable
   Other (custom text)
   System records missed workout
   Postconditions: Missed workout is logged
   UC-6.2: Generate Makeup Workout Plan
   Actor: System (Automated)
   Description: System automatically suggests compensation strategies
   Preconditions: User has missed a workout
   Flow:
   System detects missed workout
   System analyzes:
   Missed exercises and muscle groups
   User's remaining schedule
   Plan structure and goals
   System generates compensation actions:
   Option A: Reschedule entire session to next available day
   Option B: Distribute missed exercises across upcoming sessions
   Option C: Add weekend makeup session
   Option D: Extend program by one week
   System presents options to user
   User selects preferred strategy
   System updates workout plan accordingly
   Postconditions: Makeup plan is created
   UC-6.3: Reschedule Missed Workout
   Actor: Authenticated User
   Description: User manually reschedules a missed session
   Preconditions: Missed workout exists
   Flow:
   User views missed workouts
   User selects missed session
   User chooses new date/time
   System checks for scheduling conflicts
   System reschedules workout
   Postconditions: Workout is rescheduled
   UC-6.4: View Missed Workout Report
   Actor: Authenticated User
   Description: User reviews consistency metrics
   Preconditions: User has workout history
   Flow:
   User navigates to consistency report
   System displays:
   Total missed workouts
   Missed workout patterns (days of week, reasons)
   Compensation completion rate
   Adherence percentage
   Recommendations for improvement
   Postconditions: User views missed workout analytics

7. NUTRITION MANAGEMENT
   UC-7.1: Create Nutrition Plan
   Actor: Authenticated User
   Description: User sets up personalized meal plan
   Preconditions: User must be logged in
   Flow:
   User navigates to nutrition planning
   User enters:
   Plan name
   Linked fitness goal
   Daily calorie target
   Macronutrient distribution (protein %, carbs %, fats %)
   Allowed cheat meals per week
   User enables auto-adjustment feature
   System calculates macro targets in grams
   System saves nutrition plan
   Postconditions: Nutrition plan is created and active
   UC-7.2: Log Daily Meals
   Actor: Authenticated User
   Description: User records food intake
   Preconditions: User must be logged in
   Flow:
   User clicks "Log Meal"
   User enters:
   Meal type (breakfast, lunch, dinner, snack)
   Food name/description
   Calories
   Protein, carbs, fats (grams)
   Meal time
   Cheat meal flag (yes/no)
   Notes
   System calculates running daily totals
   System saves nutrition log
   Postconditions: Meal is logged, daily totals updated
   UC-7.3: Log Cheat Meal
   Actor: Authenticated User
   Description: User records dietary deviation
   Preconditions: User must have active nutrition plan
   Flow:
   User logs meal as normal
   User checks "This is a cheat meal"
   System calculates excess calories (vs. planned meal)
   System triggers compensation action generation
   System creates cheat meal log with:
   Excess calories
   Date
   Planned compensation strategy
   Postconditions: Cheat meal is logged, compensation triggered
   UC-7.4: Generate Cheat Meal Compensation Plan
   Actor: System (Automated)
   Description: System suggests actions to compensate for cheat meal
   Preconditions: Cheat meal has been logged
   Flow:
   System calculates excess calories (e.g., 800 calories over target)
   System generates compensation options:
   Option A: Add 30-minute cardio to next 2 workouts (burn ~400 cal)
   Option B: Reduce daily calories by 200 for next 4 days
   Option C: Combination: add 20-min cardio + reduce 100 cal/day for 3 days
   Option D: Do nothing, accept the deviation
   System presents options with explanations
   User selects preferred strategy
   System creates compensation action and adjusts plans
   Postconditions: Compensation plan is active
   UC-7.5: View Nutrition Dashboard
   Actor: Authenticated User
   Description: User monitors daily nutrition status
   Preconditions: User has logged meals
   Flow:
   User navigates to nutrition dashboard
   System displays:
   Today's calorie and macro progress (vs. targets)
   Remaining calories/macros for the day
   Recent meal logs
   Weekly cheat meal count (vs. allowed)
   Active compensation plans
   Nutritional trends (7-day, 30-day)
   Postconditions: User views nutrition status
   UC-7.6: Create Meal Template
   Actor: Authenticated User
   Description: User saves frequently eaten meals for quick logging
   Preconditions: User must have nutrition plan
   Flow:
   User navigates to meal templates
   User clicks "Create Template"
   User enters:
   Meal name
   Meal type
   Ingredients and nutritional values
   Recipe instructions
   System saves template
   Postconditions: Meal template is created
   UC-7.7: Use Meal Template
   Actor: Authenticated User
   Description: User quickly logs meal from saved template
   Preconditions: Meal templates must exist
   Flow:
   User clicks "Log Meal"
   User selects "Use Template"
   User chooses template from list
   System auto-fills meal details
   User can adjust quantities if needed
   System logs meal
   Postconditions: Meal is logged from template

8. BODY MEASUREMENT TRACKING
   UC-8.1: Record Body Measurements
   Actor: Authenticated User
   Description: User logs physical measurements
   Preconditions: User must be logged in
   Flow:
   User navigates to measurements
   User clicks "Add Measurement"
   User enters:
   Measurement date
   Weight (kg)
   Body fat percentage
   Chest, waist, hips, biceps, thighs (cm)
   Optional notes
   System validates data
   System saves measurement record
   Postconditions: Measurement is recorded
   UC-8.2: View Measurement History
   Actor: Authenticated User
   Description: User reviews measurement trends
   Preconditions: User must have measurement history
   Flow:
   User navigates to measurement history
   System displays:
   Table of all measurements with dates
   Line charts showing trends for each metric
   Progress indicators (gained/lost)
   Comparison to target weight
   User can select date range
   Postconditions: User views measurement trends
   UC-8.3: Set Measurement Goals
   Actor: Authenticated User
   Description: User defines target measurements
   Preconditions: User must be logged in
   Flow:
   User navigates to measurement goals
   User sets targets for:
   Target weight
   Target body fat percentage
   Target measurements
   Target date
   System saves goals and calculates required weekly changes
   Postconditions: Measurement goals are set
   UC-8.4: View Progress Photos
   Actor: Authenticated User
   Description: User uploads and compares transformation photos
   Preconditions: User must be logged in
   Flow:
   User navigates to progress photos
   User uploads photo with date
   System organizes photos chronologically
   User can view side-by-side comparisons
   Postconditions: Progress photo is uploaded

9. RECOVERY & WELLNESS TRACKING
   UC-9.1: Log Daily Recovery Metrics
   Actor: Authenticated User
   Description: User records recovery and wellness indicators
   Preconditions: User must be logged in
   Flow:
   User navigates to recovery tracker
   User logs:
   Sleep hours (0-12)
   Sleep quality rating (1-5)
   Stress level (1-5)
   Muscle soreness level (1-5)
   Energy level (1-5)
   Optional notes
   System saves recovery record
   Postconditions: Recovery metrics are logged
   UC-9.2: View Recovery Dashboard
   Actor: Authenticated User
   Description: User monitors recovery trends
   Preconditions: User has recovery history
   Flow:
   User navigates to recovery dashboard
   System displays:
   Average sleep duration (weekly)
   Sleep quality trends
   Stress level patterns
   Soreness by muscle group
   Energy level correlation with workout performance
   Recovery recommendations
   Postconditions: User views recovery analytics
   UC-9.3: Receive Recovery Alerts
   Actor: System (Automated)
   Description: System warns user of potential overtraining
   Preconditions: User has consistent recovery tracking
   Flow:
   System analyzes recovery patterns
   System detects warning signs:
   Sleep debt accumulating (< 6 hours for 3+ days)
   High stress sustained (4-5/5 for 5+ days)
   Persistent soreness (4-5/5 for 7+ days)
   Declining workout performance
   System generates alert with recommendations:
   Take rest day
   Reduce workout intensity
   Add stretching/mobility work
   Consult healthcare provider
   Postconditions: User receives recovery alert

10. ACHIEVEMENT & GAMIFICATION
    UC-10.1: Earn Achievement
    Actor: System (Automated)
    Description: System awards badge when criteria is met
    Preconditions: Achievement criteria defined
    Flow:
    System monitors user activities
    System detects achievement criteria met:
    "First Workout" - Complete first session
    "7-Day Streak" - Workout 7 consecutive days
    "Century Club" - Complete 100 workouts
    "Iron Pumper" - Lift 10,000 kg total volume
    "Consistency King" - 80%+ adherence for 8 weeks
    "Transformation" - Lose/gain target weight
    "Nutrition Ninja" - Track meals for 30 days
    System awards achievement and points
    System displays notification to user
    Postconditions: Achievement is earned and displayed
    UC-10.2: View Achievement Gallery
    Actor: Authenticated User
    Description: User reviews earned achievements
    Preconditions: User must be logged in
    Flow:
    User navigates to achievements
    System displays:
    All earned achievements with dates
    Locked achievements (not yet earned)
    Progress toward locked achievements
    Total points earned
    Leaderboard ranking (optional)
    Postconditions: User views achievements
    UC-10.3: Share Achievement
    Actor: Authenticated User
    Description: User shares accomplishment
    Preconditions: Achievement must be earned
    Flow:
    User selects achievement
    User clicks "Share"
    System generates shareable image/link
    User can share on social media or copy link
    Postconditions: Achievement is shared

11. COMPENSATION & ADAPTATION SYSTEM
    UC-11.1: Trigger Compensation Action
    Actor: System (Automated)
    Description: System creates adaptive response to user deviation
    Preconditions: User has logged cheat meal OR missed workout
    Flow:
    System detects triggering event:
    Cheat meal with excess calories
    Missed workout session
    System analyzes:
    Current workout plan structure
    Current nutrition plan
    User preferences (allow auto-adjust)
    Historical adherence patterns
    System generates compensation action with:
    Action type (add cardio, reduce calories, reschedule workout)
    Action description
    Scheduled date
    Calorie adjustment amount
    Detailed implementation plan
    System links action to both workout and nutrition plans
    Postconditions: Compensation action is created and pending
    UC-11.2: Review Compensation Options
    Actor: Authenticated User
    Description: User reviews and selects compensation strategy
    Preconditions: Compensation action has been triggered
    Flow:
    User receives notification of compensation action
    User navigates to compensation dashboard
    System displays:
    Triggering event details
    Multiple compensation options
    Expected impact of each option
    Recommendation based on user goals
    User selects preferred option
    System activates selected compensation
    Postconditions: Compensation action is activated
    UC-11.3: Apply Nutrition Adjustment
    Actor: System (Automated)
    Description: System temporarily modifies nutrition targets
    Preconditions: Compensation action selected
    Flow:
    System creates nutrition adjustment record
    System modifies daily targets:
    Reduce calories by specified amount
    Adjust macro distribution if needed
    Set valid date range (e.g., next 3-5 days)
    System displays adjusted targets on nutrition dashboard
    System tracks user adherence to adjustment
    After valid period, system restores original targets
    Postconditions: Nutrition targets temporarily adjusted
    UC-11.4: Apply Workout Adjustment
    Actor: System (Automated)
    Description: System modifies workout schedule or content
    Preconditions: Compensation action selected
    Flow:
    System creates makeup workout record
    System applies selected strategy:
    Reschedule: Move entire session to new date
    Distribute: Add missed exercises to existing sessions
    Add Session: Create new workout day
    Extend Program: Push end date by one week
    System updates workout plan schedule
    System notifies user of changes
    User sees updated schedule
    Postconditions: Workout plan adjusted
    UC-11.5: Complete Compensation Action
    Actor: Authenticated User
    Description: User fulfills compensation requirement
    Preconditions: Compensation action is active
    Flow:
    User completes required action:
    Finishes added cardio session
    Adheres to reduced calorie targets
    Completes makeup workout
    System detects completion
    System marks compensation as fulfilled
    System updates user stats and adherence metrics
    Postconditions: Compensation action completed
    UC-11.6: View Compensation History
    Actor: Authenticated User
    Description: User reviews past adaptations
    Preconditions: User has compensation history
    Flow:
    User navigates to compensation history
    System displays:
    List of all compensation events
    Triggering causes
    Selected strategies
    Completion status
    Effectiveness metrics
    User can filter by type or date range
    Postconditions: User views compensation history

12. GOAL & RECOMMENDATION MANAGEMENT
    UC-12.1: Browse Fitness Goals
    Actor: Authenticated User
    Description: User views available fitness goal templates
    Preconditions: None
    Flow:
    User navigates to goals library
    System displays predefined goals:
    Muscle Gain: High volume, moderate reps (8-12), 60-90s rest
    Fat Loss: Moderate volume, higher reps (12-15), 30-60s rest
    Strength: Low reps (3-6), heavy weight, 2-3min rest
    Endurance: High reps (15+), low rest (< 30s)
    General Fitness: Balanced approach
    Each goal includes:
    Description
    Recommended training frequency
    Typical workout structure
    Calorie adjustment recommendations
    Postconditions: User views goal details
    UC-12.2: Set Primary Fitness Goal
    Actor: Authenticated User
    Description: User selects main training objective
    Preconditions: User must be logged in
    Flow:
    User selects fitness goal
    System updates user profile
    System adjusts recommendations based on goal:
    Exercise suggestions
    Rep/set schemes
    Nutrition targets
    Rest day frequency
    Postconditions: Primary goal is set
    UC-12.3: Receive Exercise Recommendations
    Actor: System (Automated)
    Description: System suggests exercises based on user context
    Preconditions: User is creating/editing workout plan
    Flow:
    User is adding exercise to session
    System analyzes:
    Current session's exercises
    Muscle groups already targeted
    User's fitness goal
    User's fitness level
    Available equipment
    Historical preferences
    System recommends 5-10 exercises with rationale:
    "Complement chest press with rows for balance"
    "Add leg curls to target hamstrings"
    "Include core work for stability"
    User can select from recommendations
    **

13. REPORTING & ANALYTICS
    UC-13.1: Generate Workout Summary Report
    Actor: Authenticated User
    Description: User creates comprehensive workout performance report
    Preconditions: User has workout history
    Flow:
    User navigates to reports
    User selects "Workout Summary Report"
    User chooses date range (weekly, monthly, custom)
    System generates report with:
    Total workouts completed
    Total duration and calories burned
    Adherence percentage
    Volume lifted by muscle group
    Most improved exercises
    Missed workout analysis
    Recommended adjustments
    User can export as PDF or share
    Postconditions: Report is generated
    UC-13.2: Generate Nutrition Report
    Actor: Authenticated User
    Description: User creates dietary analysis report
    Preconditions: User has nutrition logs
    Flow:
    User navigates to reports
    User selects "Nutrition Report"
    User chooses date range
    System generates report with:
    Average daily calories and macros
    Adherence to targets (%)
    Cheat meal frequency
    Calorie surplus/deficit trends
    Macro distribution analysis
    Recommendations for improvement
    User can export report
    Postconditions: Nutrition report is generated
    UC-13.3: View Body Transformation Report
    Actor: Authenticated User
    Description: User reviews overall physical progress
    Preconditions: User has measurement history
    Flow:
    User navigates to transformation report
    System generates comprehensive view:
    Before/after measurements comparison
    Weight change chart
    Body composition changes
    Progress photos side-by-side
    Achievement timeline
    Workout volume correlation
    Nutrition adherence correlation
    System highlights milestones and improvements
    Postconditions: Transformation report is displayed
    UC-13.4: Export Data
    Actor: Authenticated User
    Description: User exports personal fitness data
    Preconditions: User must be logged in
    Flow:
    User navigates to data export
    User selects data types to export:
    Workout history
    Exercise logs
    Nutrition logs
    Measurements
    Progress photos
    User selects format (CSV, JSON, PDF)
    System packages data
    User downloads export file
    Postconditions: Data is exported

14. SEARCH & FILTERING
    UC-14.1: Search Exercises
    Actor: Authenticated User
    Description: User finds exercises using various criteria
    Preconditions: None
    Flow:
    User enters search query in exercise library
    System searches by:
    Exercise name
    Muscle group
    Equipment type
    Exercise type
    User applies filters:
    Difficulty level
    Requires spotter (yes/no)
    Favorites only
    Recently used
    System displays filtered results
    User can sort by name, difficulty, or popularity
    Postconditions: Filtered exercise list displayed
    UC-14.2: Filter Workout Plans
    Actor: Authenticated User
    Description: User finds specific workout plans
    Preconditions: User has multiple workout plans
    Flow:
    User navigates to workout plans
    User applies filters:
    Active/Inactive status
    Fitness goal
    Target muscle group
    AI-generated vs. manual
    Date created range
    System displays filtered plans
    User can sort by date or name
    Postconditions: Filtered plan list displayed

15. NOTIFICATIONS & REMINDERS
    UC-15.1: Receive Workout Reminder
    Actor: System (Automated)
    Description: System reminds user of scheduled workout
    Preconditions: User has enabled notifications and has active plan
    Flow:
    System checks user's workout schedule
    System detects upcoming workout (based on user preference: 1hr, 3hrs, or morning)
    System sends notification:
    "Time for your Upper Body workout!"
    Session details preview
    Quick start button
    User can snooze, dismiss, or start workout
    Postconditions: User is reminded of workout
    UC-15.2: Receive Streak Notification
    Actor: System (Automated)
    Description: System celebrates workout consistency
    Preconditions: User has workout streak
    Flow:
    System detects user has completed workouts on consecutive days
    System sends motivational notification:
    "🔥 5-day workout streak! Keep it up!"
    Current streak count
    Next achievement milestone
    User receives notification
    Postconditions: User is motivated by streak notification
    UC-15.3: Receive Goal Progress Update
    Actor: System (Automated)
    Description: System notifies user of milestone progress
    Preconditions: User has set goals
    Flow:
    System monitors goal progress
    System detects significant milestone:
    25%, 50%, 75%, 100% of goal achieved
    System sends notification:
    "You've lost 5kg - halfway to your goal!"
    Progress visualization
    Encouragement message
    User views progress details
    Postconditions: User is informed of progress
    UC-15.4: Receive Recovery Alert
    Actor: System (Automated)
    Description: System warns about inadequate recovery
    Preconditions: User tracks recovery metrics
    Flow:
    System analyzes recovery data
    System detects concerning patterns
    System sends alert:
    "Consider taking a rest day - recovery metrics are low"
    Specific metrics of concern
    Recommendations
    User can view details or schedule rest day
    Postconditions: User receives recovery alert

16. SYSTEM ADMINISTRATION (Admin/Trainer Role)
    UC-16.1: Manage Exercise Library
    Actor: Admin/Trainer
    Description: Privileged user manages exercise database
    Preconditions: User must have admin/trainer role
    Flow:
    Admin navigates to exercise management
    Admin can:
    Create new exercises
    Edit existing exercises
    Delete exercises (if not in use)
    Upload/update videos and images
    Define muscle group mappings
    Set equipment requirements
    Add alternative exercises
    System validates and saves changes
    Postconditions: Exercise library is updated
    UC-16.2: Manage Goals Library
    Actor: Admin
    Description: Admin configures fitness goal templates
    Preconditions: User must have admin role
    Flow:
    Admin navigates to goal management
    Admin can:
    Create new goal templates
    Edit goal parameters
    Delete goals (if not in use)
    Set recommended training protocols
    System saves changes
    Postconditions: Goals library is updated
    UC-16.3: View User Analytics (Aggregate)
    Actor: Admin
    Description: Admin reviews system-wide usage statistics
    Preconditions: User must have admin role
    Flow:
    Admin navigates to analytics dashboard
    System displays aggregate data:
    Total active users
    Average workouts per user
    Most popular exercises
    Most popular workout goals
    Average adherence rates
    Cheat meal frequency trends
    Missed workout patterns
    Feature usage statistics
    Admin can export reports
    Postconditions: Admin views system analytics

17. ONBOARDING
    UC-17.1: Complete Onboarding Steps
    Actor: New User
    Description: User progresses through configurable onboarding steps
    Preconditions: User is in onboarding flow
    Flow:
    System fetches ordered list of active onboarding steps from database
    For each step, system displays:
      - Step title (admin-configured)
      - Step description/subtitle (admin-configured)
      - Help text (admin-configured)
      - Input fields based on step type
      - Progress indicator showing completion percentage
    User completes each step and clicks "Next"
    System validates input based on step configuration
    System saves user responses to profile/preferences
    System advances to next step
    Postconditions: User progresses through onboarding
    Step Types: PERSONAL_INFO, BODY_METRICS, FITNESS_LEVEL, FITNESS_GOAL, EQUIPMENT, SCHEDULE, HEALTH_LIMITATIONS, NOTIFICATIONS

    UC-17.2: Complete Personal Information Step
    Actor: New User
    Description: User provides basic personal details
    Preconditions: Step is active and user reaches this step
    Flow:
    System displays personal info form with configured fields
    User enters:
      - Name/Nickname (if not from registration)
      - Date of Birth (if not from registration)
      - Gender (options from admin config)
      - Profile photo (optional)
    System validates and saves data
    Postconditions: Personal information is saved to user profile

    UC-17.3: Complete Body Metrics Step
    Actor: New User
    Description: User provides body measurements
    Preconditions: Step is active and user reaches this step
    Flow:
    System displays body metrics form
    User enters:
      - Current weight (kg or lbs based on user preference)
      - Target weight
      - Height (cm or ft/in)
      - Body fat percentage (optional)
    System calculates BMI if applicable
    System saves metrics to user profile
    Postconditions: Body metrics are saved

    UC-17.4: Select Fitness Level
    Actor: New User
    Description: User selects their current fitness experience level
    Preconditions: Step is active and user reaches this step
    Flow:
    System fetches fitness level options from database
    System displays options with:
      - Option label (e.g., "Beginner")
      - Description (e.g., "New to gym, less than 6 months experience")
      - Icon (optional)
    User selects one option
    System saves selection to user profile
    Postconditions: Fitness level is set
    Admin Configurable: Option labels, descriptions, icons, display order

    UC-17.5: Select Primary Fitness Goal
    Actor: New User
    Description: User selects main workout objective
    Preconditions: Step is active and user reaches this step
    Flow:
    System fetches fitness goal options from database
    System displays goal options with:
      - Goal name (e.g., "Build Muscle", "Lose Weight")
      - Description
      - Icon
      - Training focus hints
    User selects one primary goal (or multiple if configured)
    User optionally sets specific target (e.g., target weight, target date)
    System saves selection and links to FitnessGoal entity
    Postconditions: Primary fitness goal is set
    Admin Configurable: Goal options, descriptions, icons, allow multi-select flag

    UC-17.6: Select Available Equipment
    Actor: New User
    Description: User specifies workout equipment access
    Preconditions: Step is active and user reaches this step
    Flow:
    System fetches equipment options from database
    System displays equipment categories/items:
      - Gym access presets (Full Gym, Home Gym, Bodyweight Only)
      - Individual equipment items (Dumbbells, Barbell, Cable Machine, etc.)
    User selects applicable equipment
    System saves equipment preferences
    System uses this data to filter exercise recommendations
    Postconditions: Equipment preferences are saved
    Admin Configurable: Equipment options, categories, icons, descriptions

    UC-17.7: Set Workout Schedule Preferences
    Actor: New User
    Description: User configures preferred workout schedule
    Preconditions: Step is active and user reaches this step
    Flow:
    System displays schedule configuration:
      - Preferred workout days (multi-select: Mon-Sun)
      - Preferred workout duration (options: 30, 45, 60, 90 mins)
      - Preferred workout time (Morning, Afternoon, Evening)
    User makes selections
    System saves to user preferences
    Postconditions: Schedule preferences are saved
    Admin Configurable: Duration options, time of day options

    UC-17.8: Specify Health Limitations
    Actor: New User
    Description: User indicates any injuries or health conditions (optional step)
    Preconditions: Step is active and marked as optional
    Flow:
    System displays health limitation options from database:
      - Common injuries (Back pain, Knee issues, Shoulder injury, etc.)
      - Conditions (Pregnancy, Heart condition, etc.)
      - "None" option
    User selects applicable items or skips
    System saves limitations to profile
    System uses this to filter/warn on certain exercises
    Postconditions: Health limitations are recorded
    Admin Configurable: Limitation options, descriptions, affected exercises

    UC-17.9: Configure Notification Preferences
    Actor: New User
    Description: User sets up notification preferences
    Preconditions: Step is active and user reaches this step
    Flow:
    System displays notification types with toggles:
      - Workout reminders
      - Progress updates
      - Achievement notifications
      - Streak alerts
      - Recovery alerts
    User enables/disables each type
    User sets reminder timing preference
    System requests device push notification permission
    System saves notification preferences
    Postconditions: Notification preferences are configured
    Admin Configurable: Notification type labels, descriptions, default states

    UC-17.10: Skip Optional Onboarding Step
    Actor: New User
    Description: User skips a non-mandatory onboarding step
    Preconditions: Current step is marked as optional (isRequired = false)
    Flow:
    User clicks "Skip" or "Skip for now"
    System records step status as SKIPPED
    System advances to next step
    Postconditions: Step is skipped, user can complete later from settings

    UC-17.11: Generate First Workout Plan
    Actor: System / New User
    Description: System offers personalized starter plan based on onboarding data
    Preconditions: User completed required onboarding steps
    Flow:
    System offers options:
      - "Generate Personalized Plan" (AI-powered)
      - "Browse Plan Templates"
      - "Create Custom Plan"
      - "Skip for now"
    If user selects auto-generate:
      - System analyzes: fitness level, goal, equipment, schedule, limitations
      - System generates optimized starter plan
      - User previews plan overview
      - User accepts or requests regeneration
    System activates selected/generated plan
    Postconditions: User has first active workout plan

    UC-17.12: View App Tutorial
    Actor: New User
    Description: User receives optional guided tour of key app features
    Preconditions: Onboarding near completion or user requests tutorial
    Flow:
    System offers optional tutorial walkthrough
    If accepted, system displays interactive highlights:
      - Dashboard overview
      - Starting a workout
      - Browsing exercise library
      - Tracking progress
    User can skip at any point
    System tracks tutorial completion
    Postconditions: User understands basic app navigation

    UC-17.13: Complete Onboarding
    Actor: New User
    Description: User finishes onboarding and enters main app
    Preconditions: All required onboarding steps completed
    Flow:
    System shows completion summary:
      - Profile overview
      - Selected goal
      - Generated/selected plan summary
      - Personalized tips based on goals
    User clicks "Go to Dashboard"
    System marks user as onboarded (onboarding_completed = true)
    System awards "Getting Started" achievement
    System redirects to main dashboard
    Postconditions: User is fully onboarded, will not see onboarding again

    UC-17.14: Resume Incomplete Onboarding
    Actor: Returning User
    Description: User returns to complete previously incomplete onboarding
    Preconditions: User has not completed all required onboarding steps
    Flow:
    User logs in
    System detects incomplete onboarding
    System displays prompt: "Complete your profile for a personalized experience"
    User can:
      - Continue onboarding (resumes from last incomplete step)
      - Dismiss and go to dashboard
    If dismissed, reminder appears in settings/profile
    Postconditions: User continues or defers onboarding completion

18. ONBOARDING ADMINISTRATION
    UC-18.1: View Onboarding Configuration
    Actor: Admin
    Description: Admin views current onboarding setup
    Preconditions: User has admin role
    Flow:
    Admin navigates to Admin Panel > Onboarding Configuration
    System displays:
      - Ordered list of onboarding steps
      - Step status (active/inactive)
      - Required/optional flag for each step
    Admin can select any item to edit
    Postconditions: Admin views onboarding configuration

    UC-18.2: Manage Onboarding Steps
    Actor: Admin
    Description: Admin configures onboarding step sequence and properties
    Preconditions: Admin has access to onboarding configuration
    Flow:
    Admin views list of onboarding steps
    Admin can:
      - Add new step (select step type, configure content)
      - Edit existing step properties
      - Reorder steps via drag-and-drop
      - Enable/disable steps (is_active flag)
      - Set step as required or optional (is_required flag)
      - Delete step (only if no user data associated)
    System validates configuration
    System saves changes
    Changes apply to new users immediately
    Postconditions: Onboarding step configuration is updated

    UC-18.3: Configure Onboarding Step Content
    Actor: Admin
    Description: Admin edits content for a specific onboarding step
    Preconditions: Admin is editing an onboarding step
    Flow:
    Admin selects step to edit
    Admin configures:
      - Step title
      - Subtitle/description
      - Help text / instructions
      - Input validation rules
      - Skip button text (if optional)
      - Next button text
      - Step icon
    Admin can preview step appearance
    System saves changes
    Postconditions: Step content is updated

    UC-18.4: Manage Onboarding Step Options
    Actor: Admin
    Description: Admin manages selectable options for choice-based onboarding steps
    Preconditions: Step type supports selection (e.g., FITNESS_LEVEL, FITNESS_GOAL, EQUIPMENT)
    Flow:
    Admin selects step with options
    Admin views option list
    Admin can:
      - Add new option:
        - Option key (unique identifier)
        - Label (display text)
        - Description
        - Icon/image URL
        - Metadata (JSON for additional config)
      - Edit existing option
      - Reorder options
      - Enable/disable option (is_active)
      - Delete option (if not referenced by users)
    System validates and saves changes
    Postconditions: Options are updated for new users

    UC-18.5: Manage Fitness Level Options
    Actor: Admin
    Description: Admin configures fitness level choices
    Preconditions: Admin managing FITNESS_LEVEL step options
    Flow:
    Admin views fitness level options
    Admin can add/edit levels:
      - Label (e.g., "Beginner", "Intermediate", "Advanced", "Returning")
      - Description (e.g., "New to gym, less than 6 months experience")
      - Icon
      - Metadata (e.g., recommended_intensity, default_rest_time)
    System saves changes
    Postconditions: Fitness level options are updated

    UC-18.6: Manage Fitness Goal Options
    Actor: Admin
    Description: Admin configures fitness goal choices
    Preconditions: Admin managing FITNESS_GOAL step options
    Flow:
    Admin views fitness goal options
    Admin can add/edit goals:
      - Goal name (e.g., "Build Muscle", "Lose Weight", "Gain Strength")
      - Description
      - Icon
      - Training recommendations (rep ranges, rest times, frequency)
      - Nutrition hints (calorie adjustment direction)
    System links to existing FitnessGoal entities if applicable
    System saves changes
    Postconditions: Fitness goal options are updated

    UC-18.7: Manage Equipment Options
    Actor: Admin
    Description: Admin configures equipment selection options
    Preconditions: Admin managing EQUIPMENT step options
    Flow:
    Admin views equipment categories and items
    Admin can:
      - Add equipment category (e.g., "Full Gym", "Home Gym", "Bodyweight")
      - Add individual equipment items (e.g., "Dumbbells", "Barbell", "Pull-up Bar")
      - Associate items with categories
      - Set icons and descriptions
      - Link to equipment types used in exercise filtering
    System saves changes
    Postconditions: Equipment options are updated

    UC-18.8: Manage Health Limitation Options
    Actor: Admin
    Description: Admin configures health limitation/injury options
    Preconditions: Admin managing HEALTH_LIMITATIONS step options
    Flow:
    Admin views health limitation options
    Admin can add/edit:
      - Limitation name (e.g., "Lower Back Pain", "Knee Injury")
      - Description
      - Severity levels (optional)
      - Associated exercises to avoid or modify
      - Recommended alternatives
    System saves changes
    Postconditions: Health limitation options are updated

    UC-18.9: View Onboarding Analytics
    Actor: Admin
    Description: Admin reviews onboarding completion metrics
    Preconditions: Admin has access
    Flow:
    Admin navigates to Onboarding Analytics
    System displays:
      - Overall completion rate (% of users who complete all required steps)
      - Step-by-step completion rates
      - Drop-off analysis (which steps users abandon)
      - Average time to complete onboarding
      - Skip rates per optional step
      - Most selected options per step (popular goals, fitness levels, etc.)
      - Onboarding trends over time
    Admin can filter by date range
    Admin can export report
    Postconditions: Admin views onboarding insights

    UC-18.10: Preview Onboarding Flow
    Actor: Admin
    Description: Admin previews onboarding as a new user would experience it
    Preconditions: Admin has access
    Flow:
    Admin clicks "Preview Onboarding"
    System displays onboarding simulator
    Admin walks through each step as a test user
    Admin can make notes on improvements
    Preview does not affect production data
    Postconditions: Admin has previewed the onboarding experience

Onboarding Data Model Summary:
Tables:
  - onboarding_step: Defines each step (id, step_key, title, subtitle, help_text, step_type, input_type, display_order, is_required, is_active, icon_url)
  - onboarding_option: Options for selection steps (id, step_id, option_key, label, description, icon_url, display_order, is_active, metadata JSON)
  - user_onboarding_progress: Tracks user progress (id, user_id, step_id, status [PENDING/COMPLETED/SKIPPED], response_data JSON, completed_at)

Step Types:
  - PERSONAL_INFO: Text inputs for name, DOB, gender
  - BODY_METRICS: Numeric inputs for weight, height
  - FITNESS_LEVEL: Single select from admin-configured options
  - FITNESS_GOAL: Single/multi select from admin-configured options
  - EQUIPMENT: Multi-select from admin-configured options
  - SCHEDULE: Multi-select days, select duration/time
  - HEALTH_LIMITATIONS: Multi-select from admin-configured options
  - NOTIFICATIONS: Toggle switches for each notification type


