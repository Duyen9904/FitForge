import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'home_dashboard_models.dart';

/// Cycle view mode: weekly 7-day split or monthly 4-week macro cycle
enum MuscleCycleScope {
  week,
  month,
}

/// Exercise item belonging to a specific day in the muscle focus cycle
class MuscleCycleExercise {
  final String title;
  final String category;
  final String targetMuscle;
  final String setsReps;
  final String calories;
  final String heartRate;

  const MuscleCycleExercise({
    required this.title,
    required this.category,
    required this.targetMuscle,
    required this.setsReps,
    this.calories = '240 kcal',
    this.heartRate = '118 bpm',
  });
}

/// Represents one node/day in the 7-day Radial Muscle Cycle
class MuscleCycleDay {
  final int dayNumber; // 1..7
  final String shortWeekday; // Mon..Sun
  final String muscleGroup; // e.g. 'Chest & Triceps'
  final String shortLabel; // e.g. 'Chest & Tri'
  final String tagline; // e.g. 'Build a Strong Upper Body'
  final Color nodeColor; // Design system AppColors token
  final int monthlyPercentage; // Share in monthly cycle
  final bool isRestDay;
  final bool isCompleted;
  final List<MuscleCycleExercise> exercises;

  const MuscleCycleDay({
    required this.dayNumber,
    required this.shortWeekday,
    required this.muscleGroup,
    required this.shortLabel,
    required this.tagline,
    required this.nodeColor,
    required this.monthlyPercentage,
    this.isRestDay = false,
    this.isCompleted = false,
    required this.exercises,
  });

  /// Builds the 7-day muscle split cycle using AppColors design system tokens,
  /// incorporating live dashboard session info when available.
  static List<MuscleCycleDay> buildCycle({
    TodaySessionInfo? todaySession,
    int currentWeekday = 1,
    int selectedWeek = 1,
  }) {
    final defaultDays = <MuscleCycleDay>[
      const MuscleCycleDay(
        dayNumber: 1,
        shortWeekday: 'Mon',
        muscleGroup: 'Chest & Triceps',
        shortLabel: 'CHEST – TRI',
        tagline: 'Build a Strong Upper Body',
        nodeColor: AppColors.primary,
        monthlyPercentage: 18,
        exercises: [
          MuscleCycleExercise(
            title: 'Barbell Bench Press',
            category: 'muscle',
            targetMuscle: 'Chest & Triceps',
            setsReps: '3 × 10',
            calories: '260 kcal',
            heartRate: '120 bpm',
          ),
          MuscleCycleExercise(
            title: 'Incline Dumbbell Press',
            category: 'muscle',
            targetMuscle: 'Upper Chest',
            setsReps: '3 × 10',
            calories: '230 kcal',
            heartRate: '116 bpm',
          ),
          MuscleCycleExercise(
            title: 'Chest Fly (Machine/Cable)',
            category: 'weight',
            targetMuscle: 'Inner Chest',
            setsReps: '3 × 12',
            calories: '190 kcal',
            heartRate: '110 bpm',
          ),
          MuscleCycleExercise(
            title: 'Triceps Pushdown',
            category: 'weight',
            targetMuscle: 'Triceps',
            setsReps: '3 × 12',
            calories: '160 kcal',
            heartRate: '105 bpm',
          ),
        ],
      ),
      const MuscleCycleDay(
        dayNumber: 2,
        shortWeekday: 'Tue',
        muscleGroup: 'Back & Biceps',
        shortLabel: 'BACK – BI',
        tagline: 'Build a Stronger You',
        nodeColor: AppColors.accent,
        monthlyPercentage: 18,
        exercises: [
          MuscleCycleExercise(
            title: 'Lat Pulldown',
            category: 'muscle',
            targetMuscle: 'Lats & Upper Back',
            setsReps: '3 × 10',
            calories: '240 kcal',
            heartRate: '118 bpm',
          ),
          MuscleCycleExercise(
            title: 'Seated Cable Row',
            category: 'weight',
            targetMuscle: 'Mid Back',
            setsReps: '3 × 10',
            calories: '220 kcal',
            heartRate: '115 bpm',
          ),
          MuscleCycleExercise(
            title: 'Single Arm Dumbbell Row',
            category: 'muscle',
            targetMuscle: 'Back & Lats',
            setsReps: '3 × 10',
            calories: '210 kcal',
            heartRate: '114 bpm',
          ),
          MuscleCycleExercise(
            title: 'Hammer Curl',
            category: 'weight',
            targetMuscle: 'Biceps & Forearms',
            setsReps: '3 × 12',
            calories: '150 kcal',
            heartRate: '104 bpm',
          ),
        ],
      ),
      const MuscleCycleDay(
        dayNumber: 3,
        shortWeekday: 'Wed',
        muscleGroup: 'Legs & Glutes',
        shortLabel: 'LEGS – GLUTES',
        tagline: 'Build Lower Body Strength',
        nodeColor: AppColors.success,
        monthlyPercentage: 20,
        exercises: [
          MuscleCycleExercise(
            title: 'Barbell Squat',
            category: 'muscle',
            targetMuscle: 'Quads & Glutes',
            setsReps: '3 × 10',
            calories: '320 kcal',
            heartRate: '132 bpm',
          ),
          MuscleCycleExercise(
            title: 'Romanian Deadlift',
            category: 'weight',
            targetMuscle: 'Hamstrings & Glutes',
            setsReps: '3 × 10',
            calories: '290 kcal',
            heartRate: '128 bpm',
          ),
          MuscleCycleExercise(
            title: 'Walking Lunge',
            category: 'muscle',
            targetMuscle: 'Legs & Balance',
            setsReps: '3 × 12',
            calories: '250 kcal',
            heartRate: '124 bpm',
          ),
          MuscleCycleExercise(
            title: 'Hip Thrust',
            category: 'weight',
            targetMuscle: 'Glutes',
            setsReps: '3 × 12',
            calories: '220 kcal',
            heartRate: '118 bpm',
          ),
        ],
      ),
      const MuscleCycleDay(
        dayNumber: 4,
        shortWeekday: 'Thu',
        muscleGroup: 'Shoulders & Calves',
        shortLabel: 'SHOULDERS',
        tagline: 'Lift & Tone',
        nodeColor: AppColors.warning,
        monthlyPercentage: 14,
        exercises: [
          MuscleCycleExercise(
            title: 'Dumbbell Shoulder Press',
            category: 'muscle',
            targetMuscle: 'Shoulders',
            setsReps: '3 × 10',
            calories: '220 kcal',
            heartRate: '115 bpm',
          ),
          MuscleCycleExercise(
            title: 'Lateral Raise',
            category: 'weight',
            targetMuscle: 'Side Delts',
            setsReps: '3 × 12',
            calories: '160 kcal',
            heartRate: '108 bpm',
          ),
          MuscleCycleExercise(
            title: 'Rear Delt Fly',
            category: 'weight',
            targetMuscle: 'Rear Delts',
            setsReps: '3 × 12',
            calories: '155 kcal',
            heartRate: '106 bpm',
          ),
          MuscleCycleExercise(
            title: 'Standing Calf Raise',
            category: 'muscle',
            targetMuscle: 'Calves',
            setsReps: '4 × 15',
            calories: '140 kcal',
            heartRate: '102 bpm',
          ),
        ],
      ),
      const MuscleCycleDay(
        dayNumber: 5,
        shortWeekday: 'Fri',
        muscleGroup: 'Core Focus',
        shortLabel: 'CORE + ABS',
        tagline: 'Stronger from Within',
        nodeColor: AppColors.info,
        monthlyPercentage: 12,
        exercises: [
          MuscleCycleExercise(
            title: 'Plank Hold',
            category: 'muscle',
            targetMuscle: 'Deep Core',
            setsReps: '3 × 45 sec',
            calories: '150 kcal',
            heartRate: '105 bpm',
          ),
          MuscleCycleExercise(
            title: 'Hanging Knee Raise',
            category: 'muscle',
            targetMuscle: 'Lower Abs',
            setsReps: '3 × 12',
            calories: '180 kcal',
            heartRate: '114 bpm',
          ),
          MuscleCycleExercise(
            title: 'Cable Crunch',
            category: 'weight',
            targetMuscle: 'Abdominals',
            setsReps: '3 × 15',
            calories: '170 kcal',
            heartRate: '110 bpm',
          ),
        ],
      ),
      const MuscleCycleDay(
        dayNumber: 6,
        shortWeekday: 'Sat',
        muscleGroup: 'Full Body',
        shortLabel: 'FULL BODY',
        tagline: 'Bring It All Together',
        nodeColor: AppColors.secondaryDark,
        monthlyPercentage: 12,
        exercises: [
          MuscleCycleExercise(
            title: 'Kettlebell Swing',
            category: 'cardio',
            targetMuscle: 'Full Body Conditioning',
            setsReps: '3 × 15',
            calories: '290 kcal',
            heartRate: '134 bpm',
          ),
          MuscleCycleExercise(
            title: 'Goblet Squat',
            category: 'muscle',
            targetMuscle: 'Legs & Core',
            setsReps: '3 × 12',
            calories: '240 kcal',
            heartRate: '122 bpm',
          ),
          MuscleCycleExercise(
            title: 'Push Up & Dumbbell Row',
            category: 'muscle',
            targetMuscle: 'Upper Body & Back',
            setsReps: '3 × 12',
            calories: '230 kcal',
            heartRate: '120 bpm',
          ),
        ],
      ),
      const MuscleCycleDay(
        dayNumber: 7,
        shortWeekday: 'Sun',
        muscleGroup: 'Active Rest',
        shortLabel: 'REST / CARDIO',
        tagline: 'Recover & Recharge',
        nodeColor: AppColors.grey500,
        monthlyPercentage: 6,
        isRestDay: true,
        exercises: [
          MuscleCycleExercise(
            title: 'Light Cardio (Walk / Cycle)',
            category: 'cardio',
            targetMuscle: 'Cardiovascular Recovery',
            setsReps: '20–30 min',
            calories: '180 kcal',
            heartRate: '98 bpm',
          ),
          MuscleCycleExercise(
            title: 'Full Body Stretching',
            category: 'muscle',
            targetMuscle: 'Mobility & Flexibility',
            setsReps: '10–15 min',
            calories: '90 kcal',
            heartRate: '88 bpm',
          ),
          MuscleCycleExercise(
            title: 'Foam Rolling',
            category: 'weight',
            targetMuscle: 'Myofascial Release',
            setsReps: '5–10 min',
            calories: '60 kcal',
            heartRate: '84 bpm',
          ),
        ],
      ),
    ];

    return List.generate(defaultDays.length, (index) {
      final base = defaultDays[index];
      final dayNum = index + 1;
      final isTodayNode = dayNum == currentWeekday;
      final completed = selectedWeek < 2 ||
          (selectedWeek == 2 && dayNum < currentWeekday) ||
          (isTodayNode && (todaySession?.alreadyCompleted ?? false));

      if (isTodayNode && todaySession != null) {
        final dynamicMuscle = todaySession.targetMuscleGroups.isNotEmpty
            ? todaySession.targetMuscleGroups
                .map((m) => m[0].toUpperCase() + m.substring(1).toLowerCase())
                .join(' & ')
            : (todaySession.sessionName?.isNotEmpty == true
                ? todaySession.sessionName!
                : base.muscleGroup);

        return MuscleCycleDay(
          dayNumber: base.dayNumber,
          shortWeekday: base.shortWeekday,
          muscleGroup: dynamicMuscle,
          shortLabel: (dynamicMuscle.length > 14
                  ? dynamicMuscle.split(' ').first
                  : dynamicMuscle.replaceAll(' & ', ' – '))
              .toUpperCase(),
          tagline: base.tagline,
          nodeColor: base.nodeColor,
          monthlyPercentage: base.monthlyPercentage,
          isRestDay: base.isRestDay,
          isCompleted: completed,
          exercises: base.exercises,
        );
      }

      return MuscleCycleDay(
        dayNumber: base.dayNumber,
        shortWeekday: base.shortWeekday,
        muscleGroup: base.muscleGroup,
        shortLabel: base.shortLabel,
        tagline: base.tagline,
        nodeColor: base.nodeColor,
        monthlyPercentage: base.monthlyPercentage,
        isRestDay: base.isRestDay,
        isCompleted: completed,
        exercises: base.exercises,
      );
    });
  }
}
