import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../models/onboarding_response.dart';
import '../viewmodels/onboarding_state.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_progress_bar.dart';
import '../widgets/onboarding_step_content.dart';

/// Main onboarding screen with step navigation.
///
/// This screen is purely reactive — it reads state from the ViewModel
/// and delegates all logic (data, validation, submission) to it.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).loadFlow();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);

    // Listen for state changes to navigate pages
    ref.listen<OnboardingState>(onboardingViewModelProvider, (previous, next) {
      next.maybeWhen(
        complete: () => context.go(Routes.recordMeasurement),
        loaded: (flow, index, _, __) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_pageController.hasClients) return;
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
          });
        },
        orElse: () {},
      );
    });

    // Extract canGoBack and vm for the appBar
    final bool canGoBack = state.maybeWhen(
      loaded: (_, currentIndex, __, ___) => currentIndex > 0,
      submitting: (_, currentIndex, __, ___) => currentIndex > 0,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        leading: canGoBack
            ? IconButton(
                onPressed: () {
                  final vm = ref.read(onboardingViewModelProvider.notifier);
                  state.maybeWhen(
                    loaded: (_, currentIndex, __, ___) {
                      vm.goToStep(currentIndex - 1);
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    orElse: () {},
                  );
                },
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              )
            : null,
        title: const Text('Set Up Your Profile'),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (flow, currentIndex, _, isValid) =>
            _buildLoadedContent(flow, currentIndex, isValid, isSubmitting: false),
        submitting: (flow, currentIndex, stepId, _) =>
            _buildLoadedContent(flow, currentIndex, false, isSubmitting: true),
        complete: () => _buildCompleteContent(),
        error: (message) => _buildErrorContent(message),
      ),
    );
  }

  Widget _buildLoadedContent(
    flow,
    int currentIndex,
    bool isCurrentStepValid, {
    bool isSubmitting = false,
  }) {
    final theme = Theme.of(context);
    final steps = flow.steps;
    final currentStep = steps[currentIndex] as OnboardingStepResponse;
    final isOptional = currentStep.isRequired != true;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    return Stack(
      children: [
        Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: OnboardingProgressBar(
            totalSteps: flow.totalSteps ?? steps.length,
            currentStep: currentIndex,
            completedSteps: flow.completedSteps ?? 0,
          ),
        ),

        // Step content (scrollable)
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return OnboardingStepContent(step: steps[index]);
            },
          ),
        ),

        // Bottom-pinned Continue & Skip buttons
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isCurrentStepValid
                      ? () => vm.submitCurrentStep()
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              if (isOptional) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => vm.skipCurrentStep(),
                    child: const Text('Skip'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ), // end Column
    // Loading overlay — shown only during submission
    if (isSubmitting)
      Positioned.fill(
        child: Container(
          color: Colors.black26,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      ], // end Stack children
    ); // end Stack
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
