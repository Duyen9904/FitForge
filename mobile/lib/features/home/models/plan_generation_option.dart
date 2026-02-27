/// Options for workout plan generation
enum PlanGenerationOption {
  /// User creates their own plan manually
  createOwn,
  
  /// AI generates plan based on onboarding data (recommended)
  fromOnboarding,
  
  /// Custom AI generation with manual parameters
  customAI,
}
