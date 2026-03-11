/// API endpoint constants
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.14:8080/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String loginGoogle = '/auth/login/google';
  static const String register = '/auth/register';
  static const String registerGoogle = '/auth/register/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String users = '/users';
  static const String currentUser = '/users/me';
  static const String userPreferences = '/users/me/preferences';
  static const String userPrimaryGoal = '/users/me/primary-goal';

  // Workout Plan endpoints
  static const String workoutPlans = '/workout-plans';
  static const String workoutPlansGenerate = '/workout-plans/generate';
  static const String workoutPlansActive = '/workout-plans/active';
  static const String workoutPlansFilter = '/workout-plans/filter';
  static const String workoutTemplatesRecommended =
      '/workout-plans/templates/recommended';
  static String workoutPlanById(int planId) => '/workout-plans/$planId';
  static String workoutPlanToggleActive(int planId) =>
      '/workout-plans/$planId/toggle-active';
  static String workoutPlanDuplicate(int planId) =>
      '/workout-plans/$planId/duplicate';
  static String sessionExercise(int planId, int sessionId, int sessionExerciseId) =>
      '/workout-plans/$planId/sessions/$sessionId/exercises/$sessionExerciseId';
  static String workoutPlanSessions(int planId) =>
      '/workout-plans/$planId/sessions';
  static String workoutSessionExercises(int planId, int sessionId) =>
      '/workout-plans/$planId/sessions/$sessionId/exercises';
  static String workoutSessionById(int planId, int sessionId) =>
      '/workout-plans/$planId/sessions/$sessionId';

  // Exercise endpoints
  static const String exercises = '/exercises';
  static const String exerciseTypes = '/exercises/types';
  static const String exerciseCategories = '/exercises/categories';
  static const String muscleGroups = '/muscle-groups';
  static const String equipment = '/equipment';
  static const String exerciseFavorites = '/exercises/favorites';
  static const String exerciseRecommendations = '/exercises/recommendations';
  static String exerciseDetail(int id) => '/exercises/$id';
  static String exerciseAddFavorite(int id) => '/exercises/$id/favorites';
  static String exerciseRemoveFavorite(int id) => '/exercises/$id/favorites';
  static String exerciseIsFavorite(int id) => '/exercises/$id/favorites/status';
  static String exerciseAlternatives(int id) => '/exercises/$id/alternatives';

  // Workout Execution endpoints (WorkoutExecutionController: /workouts)
  static const String workoutStart = '/workouts/start';
  static String workoutLog(int progressId) => '/workouts/$progressId/log';
  static String workoutComplete(int progressId) => '/workouts/$progressId/complete';
  static String workoutSkip(int progressId) => '/workouts/$progressId/skip';
  static const String workoutHistory = '/workouts/history';
  static const String workoutCurrent = '/workouts/current';
  static String workoutById(int progressId) => '/workouts/$progressId';

  // Workout Progress endpoints (WorkoutExecutionController)
  static const String workoutWeeklyProgress = '/workouts/weekly-progress';
  static const String workoutProgressCharts = '/workouts/progress/charts';
  static const String workoutDashboard = '/workouts/dashboard';

  // Nutrition endpoints
  static const String nutrition = '/nutrition';
  static const String nutritionPlans = '/nutrition/plans';
  static const String nutritionPlansActive = '/nutrition/plans/active';
  static String nutritionPlanById(int planId) => '/nutrition/plans/$planId';
  static String nutritionPlanDeactivate(int planId) =>
      '/nutrition/plans/$planId/deactivate';
  static String nutritionPlanDays(int planId) =>
      '/nutrition/plans/$planId/days';
  static String nutritionPlanDay(int planId, int dayNumber) =>
      '/nutrition/plans/$planId/days/$dayNumber';
  static String nutritionDayMealComplete(int dayMealId) =>
      '/nutrition/day-meals/$dayMealId/complete';
  static const String nutritionMeals = '/nutrition/meals';
  static const String nutritionSummary = '/nutrition/summary';
  static const String nutritionCheatMeals = '/nutrition/cheat-meals';
  static String nutritionCompensationOptions(int cheatMealLogId) =>
      '/nutrition/cheat-meals/$cheatMealLogId/compensation-options';
  static String nutritionSelectCompensation(int cheatMealLogId) =>
      '/nutrition/cheat-meals/$cheatMealLogId/compensation';
  static const String nutritionDashboard = '/nutrition/dashboard';
  static const String nutritionTemplates = '/nutrition/templates';
  static String nutritionTemplateById(int templateId) =>
      '/nutrition/templates/$templateId';
  static const String nutritionWeekly = '/nutrition/weekly';
  static const String nutritionPlansGenerate = '/nutrition/plans/generate';
  static String nutritionPlanDayMeals(int planId, int dayNumber) =>
      '/nutrition/plans/$planId/meals/day/$dayNumber';

  // Plan Meal endpoints (under /nutrition/meals)
  static const String nutritionMealsSchedule = '/nutrition/meals/schedule';
  static String nutritionMealComplete(int planMealId) =>
      '/nutrition/meals/$planMealId/complete';
  static String nutritionMealSkip(int planMealId) =>
      '/nutrition/meals/$planMealId/skip';

  // AI-based nutrition endpoints
  static const String nutritionGenerateAi = '/nutrition/plans/generate-ai';
  static String nutritionAdjustAi(int planId) =>
      '/nutrition/plans/$planId/adjust-ai';


  // Recovery endpoints
  static const String recovery = '/recovery';

  // Achievement endpoints
  static const String achievements = '/achievements';

  // Goal endpoints
  static const String goals = '/goals';

  // Measurement endpoints
  static const String measurements = '/measurements';
  static const String measurementsLatest = '/measurements/latest';
  static String measurementById(int id) => '/measurements/$id';
  static const String measurementsImportInbody = '/measurements/import/inbody';
  static const String measurementsImportInbodyManual =
      '/measurements/import/inbody/manual';
  static const String measurementsGoals = '/measurements/goals';
  static const String measurementsPhotos = '/measurements/photos';
  static String measurementPhotoById(int photoId) =>
      '/measurements/photos/$photoId';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String notificationsUnread = '/notifications/unread';
  static const String notificationsUnreadCount = '/notifications/unread/count';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationDevices = '/notifications/devices';
  static String notificationMarkRead(int id) => '/notifications/$id/read';
  static String notificationMarkActed(int id) => '/notifications/$id/acted';
  static String notificationsByType(String type) => '/notifications/type/$type';

  // Report endpoints
  static const String reports = '/reports';

  // Recommendation endpoints (migrated)
  static const String recommendationsWorkoutGenerate = '/workout-plans/generate/recommended';
  static String recommendationsWorkoutAdjust(int planId) => '/workout-plans/$planId/adjust';
  static String recommendationsWorkoutSessionDay(int planId, int dayNumber) =>
      '/workout-plans/$planId/sessions/day/$dayNumber';
  static String workoutPlanSessionsWeek(int planId, int weekNumber) =>
      '/workout-plans/$planId/sessions/week/$weekNumber';
  static String workoutSessionReschedule(int planId, int sessionId) =>
      '/workout-plans/$planId/sessions/$sessionId/reschedule';
  static const String recommendationsNutritionGenerate = '/nutrition/plans/generate';
  static String recommendationsNutritionAdjust(int planId) => '/nutrition/plans/$planId/adjust';
  static String recommendationsNutritionMealsDay(int planId, int dayNumber) =>
      '/nutrition/plans/$planId/meals/day/$dayNumber';

  // Onboarding endpoints
  static const String onboardingFlow = '/onboarding/flow';
  static const String onboardingSteps = '/onboarding/steps';
  static const String onboardingComplete = '/onboarding/complete';
  static const String onboardingStatus = '/onboarding/status';

  // Missed Workout endpoints
  static const String missedWorkouts = '/missed-workouts';
  static const String missedWorkoutsUnaddressed = '/missed-workouts/unaddressed';
  static const String missedWorkoutsMakeupWorkouts = '/missed-workouts/makeup-workouts';
  static const String missedWorkoutsReport = '/missed-workouts/report';
  static String missedWorkoutById(int id) => '/missed-workouts/$id';
  static String missedWorkoutMakeupOptions(int id) =>
      '/missed-workouts/$id/makeup-options';
  static String missedWorkoutMakeup(int id) => '/missed-workouts/$id/makeup';
  static String missedWorkoutReschedule(int id) =>
      '/missed-workouts/$id/reschedule';

  // GCP Media endpoints
  static const String gcpUpload = '/gcp/upload';
  static const String gcpSignedUrl = '/gcp/signed-url';
  static const String gcpDelete = '/gcp';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 120);
}
