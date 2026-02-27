import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../models/onboarding_response.dart';
import '../viewmodels/onboarding_state.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_progress_bar.dart';
import '../widgets/onboarding_step_content.dart';

/// Main onboarding screen with step navigation
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Load the onboarding flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).loadFlow();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleStepSubmit(int stepId, Map<String, dynamic> data) {
    ref.read(onboardingViewModelProvider.notifier).submitStep(stepId, data);
  }

  void _handleSkip(int stepId) {
    ref.read(onboardingViewModelProvider.notifier).skipStep(stepId);
  }

  void _goBack() {
    final state = ref.read(onboardingViewModelProvider);
    state.maybeWhen(
      loaded: (flow, currentIndex) {
        if (currentIndex > 0) {
          ref.read(onboardingViewModelProvider.notifier).goToStep(currentIndex - 1);
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);

    // Listen for state changes to navigate
    ref.listen<OnboardingState>(onboardingViewModelProvider, (previous, next) {
      next.maybeWhen(
        complete: () {
          context.go(Routes.recordMeasurement);
        },
        loaded: (flow, index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_pageController.hasClients) {
              final fromLoadingOrInitial = previous == null ||
                  previous is OnboardingLoading ||
                  previous is OnboardingInitial;
              if (fromLoadingOrInitial) {
                _pageController.jumpToPage(index);
              } else {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          });
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (flow, currentIndex) => _buildLoadedContent(flow, currentIndex),
          submitting: (flow, currentIndex, stepId) => Stack(
            children: [
              _buildLoadedContent(flow, currentIndex),
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          complete: () => _buildCompleteContent(),
          error: (message) => _buildErrorContent(message),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(flow, int currentIndex) {
    final theme = Theme.of(context);
    final steps = flow.steps;
    final canGoBack = currentIndex > 0;

    return Column(
      children: [
        // App bar with back button and progress
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  if (canGoBack)
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'Set Up Your Profile',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              OnboardingProgressBar(
                totalSteps: flow.totalSteps ?? steps.length,
                currentStep: currentIndex,
                completedSteps: flow.completedSteps ?? 0,
              ),
            ],
          ),
        ),

        // Step content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return _buildStepContent(step);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(OnboardingStepResponse step) {
    final stepId = step.stepId ?? 0;
    return OnboardingStepContent(
      step: step,
      onSubmit: (data) => _handleStepSubmit(stepId, data),
      onSkip: step.isRequired != true ? () => _handleSkip(stepId) : null,
    );
  }

  Widget _buildCompleteContent() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'You\'re All Set!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your profile is ready. Let\'s start your fitness journey!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go(Routes.home),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                ref.read(onboardingViewModelProvider.notifier).loadFlow();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
