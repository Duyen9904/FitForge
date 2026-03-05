/// Route path constants
class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String recordMeasurement = '/record-measurement';
  static const String home = '/home';
  static const String workouts = '/workouts';
  static String workoutPlanDetail(int planId) => '/workouts/$planId';
  static const String workoutPlanDetailSegment = ':planId';
  static const String exercises = '/exercises';
  static const String nutrition = '/nutrition';
  static const String profile = '/profile';
  
  // Exercise child routes (full paths)
  static String exerciseDetail(int id) => '/exercises/$id';
  static const String exerciseFavorites = '/exercises/favorites';
  
  // Exercise child route segments (for GoRouter nested routes)
  static const String exerciseFavoritesSegment = 'favorites';
  static const String exerciseDetailSegment = ':id';
  static const String exercisesByTypeSegment = 'type/:typeName';
  static String exercisesByType(String typeName) => '/exercises/type/$typeName';

  // Exercise categories child route segments
  static const String exerciseCategoriesSegment = 'type/:typeName/categories';
  static String exerciseCategories(String typeName) => '/exercises/type/$typeName/categories';
  static const String exercisesByCategorySegment = 'type/:typeName/category/:categoryName';
  static String exercisesByCategory(String typeName, String categoryName) => '/exercises/type/$typeName/category/$categoryName';

  
  // Equipment routes (full paths)
  static const String equipmentList = '/equipment';
  static String equipmentExercises(int id) => '/equipment/$id/exercises';
  
  // Equipment child route segments (for GoRouter nested routes)
  static const String equipmentExercisesSegment = ':id/exercises';
  
  // Recommendation routes
  static const String workoutRecommendation = '/recommendation/workout';
  static const String nutritionRecommendation = '/recommendation/nutrition';
  static String workoutSession(int planId, int dayNumber) => '/recommendation/workout/$planId/session/$dayNumber';
  static String mealDetail(int mealId) => '/recommendation/nutrition/meal/$mealId';
  
  // Recommendation child route segments
  static const String workoutSessionSegment = ':planId/session/:dayNumber';
  static const String mealDetailSegment = 'meal/:mealId';

  // Workout execution routes
  static const String workoutActivity = '/workout-activity';
  static const String workoutCountdown = '/workout-countdown';
  static const String exerciseExecution = '/exercise-execution';
  static const String restTimer = '/rest-timer';
  static const String workoutCongratulations = '/workout-congratulations';
  static const String createWorkoutPlan = '/create-workout-plan';
  static const String generateAIPlan = '/generate-ai-plan';

  // Settings route
  static const String settings = '/settings';

  // Profile sub-routes
  static const String onboardingReview = '/profile/onboarding-review';
  static const String fitnessGoals = '/profile/fitness-goals';
  static const String appSettings = '/settings'; // alias
  static const String trainingPreferences = '/profile/training-preferences';
  static const String nutritionTargets = '/profile/nutrition-targets';
}

/// Route name constants
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String onboarding = 'onboarding';
  static const String recordMeasurement = 'recordMeasurement';
  static const String home = 'home';
  static const String workouts = 'workouts';
  static const String workoutPlanDetail = 'workoutPlanDetail';
  static const String exercises = 'exercises';
  static const String nutrition = 'nutrition';
  static const String profile = 'profile';
  
  // Exercise child routes
  static const String exerciseDetail = 'exerciseDetail';
  static const String exerciseFavorites = 'exerciseFavorites';
  static const String exercisesByType = 'exercisesByType';
  static const String exerciseCategories = 'exerciseCategories';
  static const String exercisesByCategory = 'exercisesByCategory';
  
  // Equipment routes
  static const String equipmentList = 'equipmentList';
  static const String equipmentExercises = 'equipmentExercises';

  
  // Recommendation routes
  static const String workoutRecommendation = 'workoutRecommendation';
  static const String nutritionRecommendation = 'nutritionRecommendation';
  static const String workoutSession = 'workoutSession';
  static const String mealDetail = 'mealDetail';

  // Workout execution routes
  static const String workoutActivity = 'workoutActivity';
  static const String workoutCountdown = 'workoutCountdown';
  static const String exerciseExecution = 'exerciseExecution';
  static const String restTimer = 'restTimer';
  static const String workoutCongratulations = 'workoutCongratulations';
  static const String createWorkoutPlan = 'createWorkoutPlan';
  static const String generateAIPlan = 'generateAIPlan';

  // Settings route
  static const String settings = 'settings';

  // Profile sub-routes
  static const String onboardingReview = 'onboardingReview';
  static const String fitnessGoals = 'fitnessGoals';
  static const String appSettings = 'settings'; // alias
  static const String trainingPreferences = 'trainingPreferences';
  static const String nutritionTargets = 'nutritionTargets';
}
