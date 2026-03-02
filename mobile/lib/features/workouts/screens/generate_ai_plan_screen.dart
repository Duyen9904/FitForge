import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/config/routes.dart';
import '../viewmodels/generate_ai_plan_viewmodel.dart';
import '../viewmodels/generate_ai_plan_state.dart';
import '../widgets/generate_ai_plan/ai_plan_header.dart';
import '../widgets/generate_ai_plan/ai_plan_form_body.dart';
import '../widgets/generate_ai_plan/ai_plan_loading_view.dart';
import '../widgets/generate_ai_plan/ai_plan_error_view.dart';

/// Screen for generating an AI-powered workout plan
class GenerateAIPlanScreen extends ConsumerStatefulWidget {
  const GenerateAIPlanScreen({super.key});

  @override
  ConsumerState<GenerateAIPlanScreen> createState() =>
      _GenerateAIPlanScreenState();
}

class _GenerateAIPlanScreenState extends ConsumerState<GenerateAIPlanScreen> {
  final _additionalInfoController = TextEditingController();
  bool _listenedForSuccess = false;

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateAIPlanViewModelProvider);
    final vm = ref.read(generateAIPlanViewModelProvider.notifier);

    // Listen for success → navigate to plan detail
    ref.listen<GenerateAIPlanState>(generateAIPlanViewModelProvider,
        (prev, next) {
      if (next is GenerateAIPlanSuccess && !_listenedForSuccess) {
        _listenedForSuccess = true;
        context.go(Routes.workoutPlanDetail(next.planId));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Generate AI Plan'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
      ),
      body: state.when(
        editing: (selectedGroups, durationWeeks, startDate, additionalInfo) =>
            SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AIPlanHeader(),
              const SizedBox(height: AppDimensions.spacing24),
              AIPlanFormBody(
                viewModel: vm,
                selectedMuscleGroups: selectedGroups,
                durationWeeks: durationWeeks,
                startDate: startDate,
                additionalInfo: additionalInfo,
                additionalInfoController: _additionalInfoController,
              ),
            ],
          ),
        ),
        submitting: () => const AIPlanLoadingView(),
        success: (_) => const SizedBox.shrink(),
        error: (message) => AIPlanErrorView(
          message: message,
          onRetry: vm.retryFromError,
        ),
      ),
    );
  }
}
