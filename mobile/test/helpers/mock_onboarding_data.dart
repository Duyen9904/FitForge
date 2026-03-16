/// Mock data for onboarding widget tests.
/// Onboarding option cards use simple label/description strings.

class MockOnboardingOption {
  final String label;
  final String? description;
  final String? iconUrl;

  const MockOnboardingOption({
    required this.label,
    this.description,
    this.iconUrl,
  });
}

const mockGoalOptions = [
  MockOnboardingOption(
    label: 'Lose Weight',
    description: 'Burn fat and get lean',
  ),
  MockOnboardingOption(
    label: 'Build Muscle',
    description: 'Increase strength and muscle mass',
  ),
  MockOnboardingOption(
    label: 'Stay Fit',
    description: 'Maintain your current fitness level',
  ),
];

const mockFitnessLevels = [
  MockOnboardingOption(label: 'Beginner', description: 'New to working out'),
  MockOnboardingOption(label: 'Intermediate', description: '1-3 years experience'),
  MockOnboardingOption(label: 'Advanced', description: '3+ years experience'),
];
