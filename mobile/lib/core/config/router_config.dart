import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/exercises/screens/equipment_list_screen.dart';
import '../../features/exercises/screens/exercise_detail_screen.dart';
import '../../features/exercises/screens/exercise_library_screen.dart';
import '../../features/exercises/screens/exercise_categories_screen.dart';
import '../../features/exercises/screens/exercises_by_type_screen.dart';
import '../../features/exercises/screens/favorites_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/nutrition/screens/meal_templates_screen.dart';
import '../../features/nutrition/screens/add_meal_plan_screen.dart';
import '../../features/nutrition/screens/template_meal_detail_screen.dart';
import '../../features/nutrition/screens/log_meal_screen.dart';
import '../../features/nutrition/models/nutrition_models.dart';
import '../../features/measurements/screens/record_measurement_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/onboarding_review_screen.dart';
import '../../features/profile/screens/fitness_goals_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/profile/screens/training_preferences_screen.dart';
import '../../features/profile/screens/nutrition_targets_screen.dart';
import '../../features/recommendation/screens/workout_recommendation_screen.dart';
import '../../features/recommendation/screens/workout_session_detail_screen.dart';
import '../../features/recommendation/screens/nutrition_recommendation_screen.dart';
import '../../features/recommendation/screens/meal_detail_screen.dart';
import '../../features/recommendation/models/recommendation_models.dart' hide SessionExerciseResponse;
import '../../features/workout_execution/screens/workout_activity_screen.dart';
import '../../features/workout_execution/screens/workout_countdown_screen.dart';
import '../../features/workout_execution/screens/exercise_execution_screen.dart';
import '../../features/workout_execution/screens/rest_timer_screen.dart';
import '../../features/workout_execution/screens/workout_congratulations_screen.dart';
import '../../features/workouts/models/workout_plan_models.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/workouts/screens/workout_plans_screen.dart';
import '../../features/workouts/screens/workout_plan_detail_screen.dart';
import '../../features/workouts/screens/create_workout_plan_screen.dart';
import '../../features/workouts/screens/generate_ai_plan_screen.dart';
import '../../ui/core/main_navigation_shell.dart';
import '../state/app_flow_state.dart';
import 'routes.dart';

/// A ChangeNotifier that listens to auth state changes
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(this._ref) {
    _ref.listen(authViewModelProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

/// Provider for the auth change notifier
final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final isAuthUnknown = authState.maybeWhen(
        initial: () => true,
        orElse: () => false,
      );
      final isLoggedIn = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register;
      final isSplashRoute = state.matchedLocation == Routes.splash;
      final isOnboardingRoute = state.matchedLocation == Routes.onboarding;
      final isRecordMeasurementRoute =
          state.matchedLocation == Routes.recordMeasurement;

      // Auth status unknown (e.g. app restarted): go through splash to restore from storage
      if (isAuthUnknown && !isSplashRoute) return Routes.splash;

      // Don't redirect on splash screen
      if (isSplashRoute) return null;

      // Check app flow status for authenticated users (after splash)
      if (isLoggedIn && !isSplashRoute) {
        final flowState = ref.read(appFlowStateProvider);
        
        // If flow state not loaded yet, let splash handle it
        if (flowState == null && !isAuthRoute) {
          return Routes.splash;
        }
        
        // Skip checks if already on these routes (prevent redirect loops)
        if (!isOnboardingRoute && !isRecordMeasurementRoute && !isAuthRoute) {
          if (flowState != null) {
            if (!flowState.onboardingComplete) {
              return Routes.onboarding;
            }
            if (!flowState.measurementComplete) {
              return Routes.recordMeasurement;
            }
          }
        }
      }

      // Allow onboarding and record-measurement routes for authenticated users
      if (isLoggedIn && (isOnboardingRoute || isRecordMeasurementRoute)) {
        return null;
      }

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isAuthRoute) {
        return Routes.login;
      }

      // Redirect to home if authenticated and on auth route
      if (isLoggedIn && isAuthRoute) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: Routes.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Onboarding Route
      GoRoute(
        path: Routes.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Record measurement (post-onboarding step)
      GoRoute(
        path: Routes.recordMeasurement,
        name: RouteNames.recordMeasurement,
        builder: (context, state) => const RecordMeasurementScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.workouts,
            name: RouteNames.workouts,
            builder: (context, state) => const WorkoutPlansScreen(),
            routes: [
              GoRoute(
                path: Routes.workoutPlanDetailSegment,
                name: RouteNames.workoutPlanDetail,
                builder: (context, state) {
                  final planId =
                      int.parse(state.pathParameters['planId']!);
                  return WorkoutPlanDetailScreen(planId: planId);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.exercises,
            name: RouteNames.exercises,
            builder: (context, state) => const ExerciseLibraryScreen(),
            routes: [
              GoRoute(
                path: Routes.exerciseFavoritesSegment,
                name: RouteNames.exerciseFavorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: Routes.exercisesByTypeSegment,
                name: RouteNames.exercisesByType,
                builder: (context, state) {
                  final typeName = state.pathParameters['typeName']!;
                  return ExerciseCategoriesScreen(
                    typeName: typeName,
                  );
                },
              ),
              GoRoute(
                path: Routes.exercisesByCategorySegment,
                name: RouteNames.exercisesByCategory,
                builder: (context, state) {
                  final typeName = state.pathParameters['typeName']!;
                  final categoryName = state.pathParameters['categoryName']!;
                  return ExercisesByTypeScreen(
                    typeName: typeName,
                    categoryName: categoryName,
                  );
                },
              ),
              GoRoute(
                path: Routes.exerciseDetailSegment,
                name: RouteNames.exerciseDetail,
                pageBuilder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return MaterialPage(
                    key: ValueKey('exercise-detail-$id'),
                    child: ExerciseDetailScreen(exerciseId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.nutrition,
            name: RouteNames.nutrition,
            builder: (context, state) => const NutritionScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Profile sub-screens (standalone routes with push navigation)
      GoRoute(
        path: Routes.onboardingReview,
        name: RouteNames.onboardingReview,
        builder: (context, state) => const OnboardingReviewScreen(),
      ),
      GoRoute(
        path: Routes.fitnessGoals,
        name: RouteNames.fitnessGoals,
        builder: (context, state) => const FitnessGoalsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.trainingPreferences,
        name: RouteNames.trainingPreferences,
        builder: (context, state) => const TrainingPreferencesScreen(),
      ),
      GoRoute(
        path: Routes.nutritionTargets,
        name: RouteNames.nutritionTargets,
        builder: (context, state) => const NutritionTargetsScreen(),
      ),
      GoRoute(
        path: Routes.mealTemplates,
        name: RouteNames.mealTemplates,
        builder: (context, state) => const MealTemplatesScreen(),
      ),
      GoRoute(
        path: Routes.addMealPlan,
        name: RouteNames.addMealPlan,
        builder: (context, state) {
          final template = state.extra as MealTemplate;
          return AddMealPlanScreen(template: template);
        },
      ),
      GoRoute(
        path: Routes.templateMealDetail,
        name: RouteNames.templateMealDetail,
        builder: (context, state) {
          final template = state.extra as MealTemplate;
          return TemplateMealDetailScreen(template: template);
        },
      ),
      GoRoute(
        path: Routes.logMeal,
        name: RouteNames.logMeal,
        builder: (context, state) => const LogMealScreen(),
      ),

      // Equipment routes (outside shell - standalone routes)
      GoRoute(
        path: Routes.equipmentList,
        name: RouteNames.equipmentList,
        builder: (context, state) => const EquipmentListScreen(),
        routes: [
          GoRoute(
            path: Routes.equipmentExercisesSegment,
            name: RouteNames.equipmentExercises,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final equipmentName = state.extra as String? ?? 'Equipment';
              return ExercisesByTypeScreen(
                equipmentId: id,
                equipmentName: equipmentName,
              );
            },
          ),
        ],
      ),

      // Recommendation routes (outside shell - standalone routes)
      GoRoute(
        path: Routes.workoutRecommendation,
        name: RouteNames.workoutRecommendation,
        builder: (context, state) => const WorkoutRecommendationScreen(),
        routes: [
          GoRoute(
            path: Routes.workoutSessionSegment,
            name: RouteNames.workoutSession,
            builder: (context, state) {
              final planId = int.parse(state.pathParameters['planId']!);
              final dayNumber = int.parse(state.pathParameters['dayNumber']!);
              return WorkoutSessionDetailScreen(
                planId: planId,
                dayNumber: dayNumber,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.nutritionRecommendation,
        name: RouteNames.nutritionRecommendation,
        builder: (context, state) => const NutritionRecommendationScreen(),
        routes: [
          GoRoute(
            path: Routes.mealDetailSegment,
            name: RouteNames.mealDetail,
            builder: (context, state) {
              final meal = state.extra as MealTemplateResponse;
              return MealDetailScreen(meal: meal);
            },
          ),
        ],
      ),

      // Workout execution routes (standalone)
      GoRoute(
        path: Routes.workoutActivity,
        name: RouteNames.workoutActivity,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final exercises = extra?['exercises'] as List<dynamic>?;
          return WorkoutActivityScreen(
            sessionId: extra?['sessionId'] as int?,
            sessionName: extra?['sessionName'] as String?,
            exercises: exercises?.cast<SessionExerciseResponse>() ?? [],
          );
        },
      ),
      GoRoute(
        path: Routes.workoutCountdown,
        name: RouteNames.workoutCountdown,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final exercises = extra?['exercises'] as List<dynamic>?;
          return WorkoutCountdownScreen(
            sessionId: extra?['sessionId'] as int?,
            exercises: exercises?.cast<SessionExerciseResponse>() ?? [],
          );
        },
      ),
      GoRoute(
        path: Routes.exerciseExecution,
        name: RouteNames.exerciseExecution,
        builder: (context, state) => const ExerciseExecutionScreen(),
      ),
      GoRoute(
        path: Routes.restTimer,
        name: RouteNames.restTimer,
        builder: (context, state) => const RestTimerScreen(),
      ),
      GoRoute(
        path: Routes.workoutCongratulations,
        name: RouteNames.workoutCongratulations,
        builder: (context, state) => const WorkoutCongratulationsScreen(),
      ),

      // Create workout plan route
      GoRoute(
        path: Routes.createWorkoutPlan,
        name: RouteNames.createWorkoutPlan,
        builder: (context, state) => const CreateWorkoutPlanScreen(),
      ),

      // Generate AI workout plan route
      GoRoute(
        path: Routes.generateAIPlan,
        name: RouteNames.generateAIPlan,
        builder: (context, state) => const GenerateAIPlanScreen(),
      ),
    ],
  );
});
