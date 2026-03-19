import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/workout_execution_viewmodel.dart';
import '../viewmodels/workout_execution_state.dart';
import '../widgets/congratulations_trophy.dart';
import '../widgets/workout_stats_row.dart';
import '../widgets/next_workout_button.dart';

/// Workout Congratulations Screen — workout complete!
/// Features animated trophy, motivational quote, count-up stats,
/// check-in photo upload, and a share workout button.
class WorkoutCongratulationsScreen extends ConsumerStatefulWidget {
  const WorkoutCongratulationsScreen({super.key});

  @override
  ConsumerState<WorkoutCongratulationsScreen> createState() =>
      _WorkoutCongratulationsScreenState();
}

class _WorkoutCongratulationsScreenState
    extends ConsumerState<WorkoutCongratulationsScreen> {
  bool _hasCompleted = false;

  /// Proof photo upload state
  bool _isUploadingProof = false;
  bool _proofUploaded = false;

  final _imagePicker = ImagePicker();

  static const _motivationalQuotes = [
    'Every workout counts. You showed up today! 💪',
    'Consistency beats intensity. Keep going!',
    'The pain you feel today is the strength you feel tomorrow.',
    'Strong is the new beautiful. Well done!',
    'You didn\'t come this far to only come this far.',
    'Your body hears everything your mind says. Stay positive!',
  ];

  late String _quote;

  @override
  void initState() {
    super.initState();
    _quote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completeIfNeeded();
    });
  }

  Future<void> _completeIfNeeded() async {
    if (_hasCompleted) return;
    _hasCompleted = true;

    final state = ref.read(workoutExecutionViewModelProvider);
    if (state is WorkoutExecutionCompleting) {
      final vm = ref.read(workoutExecutionViewModelProvider.notifier);
      await vm.completeWorkout(
        difficultyRating: 3,
        moodRating: 'GOOD',
      );
    }
  }

  /// Pick and upload a check-in proof photo.
  Future<void> _pickAndUploadProofPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Check-in Photo',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final pickedFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    setState(() => _isUploadingProof = true);

    final file = File(pickedFile.path);
    final vm = ref.read(workoutExecutionViewModelProvider.notifier);
    final success = await vm.uploadWorkoutProof(file);

    if (!mounted) return;

    setState(() {
      _isUploadingProof = false;
      if (success) _proofUploaded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Check-in photo uploaded!'
              : 'Failed to upload photo. Please try again.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutExecutionViewModelProvider);

    return state.maybeWhen(
      completed: (result, totalExercises, totalCalories, totalMinutes) {
        return _buildSuccessScreen(
          context,
          exercises: totalExercises,
          calories: totalCalories,
          minutes: totalMinutes,
        );
      },
      completing: (_) {
        return _buildLoadingScreen(context);
      },
      error: (message) {
        final vm = ref.read(workoutExecutionViewModelProvider.notifier);
        return _buildSuccessScreen(
          context,
          exercises: vm.exercises.length,
          calories: 0,
          minutes: 0,
        );
      },
      orElse: () {
        return _buildSuccessScreen(
          context,
          exercises: 0,
          calories: 0,
          minutes: 0,
        );
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CongratulationsTrophy(),
              const SizedBox(height: AppDimensions.spacing24),
              Text(
                'Finishing up...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              const CircularProgressIndicator(color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(
    BuildContext context, {
    required int exercises,
    required int calories,
    required int minutes,
  }) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.primary,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated Trophy
              const CongratulationsTrophy(),

              const SizedBox(height: AppDimensions.spacing24),

              // Title
              Text(
                'Workout Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
              ),

              const SizedBox(height: AppDimensions.spacing12),

              // Motivational quote
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing32,
                ),
                child: Text(
                  _quote,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 1),

              // Stats
              WorkoutStatsRow(
                exercises: exercises,
                calories: calories,
                minutes: minutes,
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // ── Add Check-in Photo Button ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing40,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: _proofUploaded
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: AppColors.success.withValues(alpha: 0.9),
                          ),
                          label: Text(
                            'Photo Added',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color:
                                      AppColors.success.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  AppColors.success.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusRound),
                            ),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: _isUploadingProof
                              ? null
                              : _pickAndUploadProofPhoto,
                          icon: _isUploadingProof
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 20,
                                  color:
                                      AppColors.white.withValues(alpha: 0.8),
                                ),
                          label: Text(
                            _isUploadingProof
                                ? 'Uploading...'
                                : 'Add Check-in Photo',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color:
                                      AppColors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  AppColors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusRound),
                            ),
                          ),
                        ),
                ),
              ),

              const Spacer(flex: 2),

              // "Back to Home" button
              NextWorkoutButton(
                label: 'BACK TO HOME',
                onPressed: () {
                  ref
                      .read(workoutExecutionViewModelProvider.notifier)
                      .resetState();
                  context.go(Routes.home);
                },
              ),

              const SizedBox(height: AppDimensions.spacing12),

              // Share workout button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing40,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      size: 20,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    label: Text(
                      'Share Workout',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusRound),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing48),
            ],
          ),
        ),
      ),
    );
  }
}
