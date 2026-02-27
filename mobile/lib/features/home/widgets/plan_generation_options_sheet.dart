import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/plan_generation_option.dart';
import 'plan_generation_option_card.dart';

/// Bottom sheet for selecting workout plan generation method
class PlanGenerationOptionsSheet extends StatelessWidget {
  final Function(PlanGenerationOption) onOptionSelected;

  const PlanGenerationOptionsSheet({
    super.key,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXLarge),
              topRight: Radius.circular(AppDimensions.radiusXLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.spacing12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Choose Generation Method',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        'Select how you\'d like to create your workout plan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey500,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacing32),

                      // Option 1: Create Your Own
                      PlanGenerationOptionCard(
                        icon: Icons.edit,
                        title: 'Create Your Own Plan',
                        description: 'Manually design your workout plan from scratch',
                        badgeText: 'Custom',
                        badgeColor: AppColors.info,
                        onTap: () {
                          Navigator.pop(context);
                          onOptionSelected(PlanGenerationOption.createOwn);
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Option 2: Based on Profile (Recommended)
                      PlanGenerationOptionCard(
                        icon: Icons.auto_awesome,
                        title: 'Based on Your Profile',
                        description: 'Generate plan using your onboarding answers',
                        badgeText: 'Recommended',
                        badgeColor: AppColors.success,
                        isRecommended: true,
                        onTap: () {
                          Navigator.pop(context);
                          onOptionSelected(PlanGenerationOption.fromOnboarding);
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Option 3: Generate with AI
                      PlanGenerationOptionCard(
                        icon: Icons.psychology,
                        title: 'Generate with AI',
                        description: 'Customize parameters for AI generation',
                        badgeText: 'Coming Soon',
                        badgeColor: AppColors.grey400,
                        onTap: () {
                          Navigator.pop(context);
                          onOptionSelected(PlanGenerationOption.customAI);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
