import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/buttons/app_buttons.dart';
import '../../auth/models/user_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    final displayName = authState.maybeWhen(
      authenticated: (user) => user.displayName,
      orElse: () => 'User',
    );
    final email = authState.maybeWhen(
      authenticated: (user) => user.email,
      orElse: () => '',
    );
    final profileImageUrl = authState.maybeWhen(
      authenticated: (user) => user.profileImageUrl,
      orElse: () => null,
    );
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(
                      displayName: displayName,
                      email: email,
                      profileImageUrl: profileImageUrl,
                    ),
                    const SizedBox(height: AppDimensions.spacing32),
                    PrimaryButton(
                      text: 'Logout',
                      icon: Icons.logout,
                      onPressed: isLoading
                          ? null
                          : () {
                              ref.read(profileViewModelProvider.notifier).logout();
                            },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
