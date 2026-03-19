import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_activity_grid.dart';
import '../widgets/profile_photos_section.dart';

/// Profile screen — redesigned to match the reference UI:
/// ProfileHeader → Statistics (Activity Heatmap) → Photos
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(profileViewModelProvider.notifier).loadProfile());
  }

  /// Show bottom sheet to pick image from camera or gallery, then upload.
  Future<void> _pickAndUploadAvatar() async {
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
              'Change Avatar',
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
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    final file = File(pickedFile.path);
    final vm = ref.read(profileViewModelProvider.notifier);
    final success = await vm.uploadAvatar(file);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Avatar updated successfully!'
              : 'Failed to upload avatar. Please try again.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(

      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: Text(
          'My Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.more_vert_outlined)
        ],
      ),
      body: profileState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => _buildErrorView(message, theme),
        loaded: (user, achievementPoints, profileSummary, isUploadingAvatar) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(profileViewModelProvider.notifier).loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Header ──
                    ProfileHeader(
                      displayName: user.displayName,
                      email: user.email,
                      profileImageUrl: user.profileImageUrl,
                      memberSince: user.dateJoined,
                      currentWeightKg: user.currentWeightKg,
                      targetWeightKg: user.targetWeightKg,
                      fitnessLevel: user.fitnessLevel,
                      primaryGoal: user.primaryGoalName,
                      onAvatarTap: _pickAndUploadAvatar,
                      isUploadingAvatar: isUploadingAvatar,
                    ),

                    // ── Statistics (Activity Heatmap) ──
                    ProfileActivityGrid(
                      heatmapData: profileSummary?.activityHeatmap,
                      totalWorkoutsCompleted:
                          profileSummary?.totalWorkoutsCompleted ?? 0,
                    ),

                    // ── Check-in Photos ──
                    ProfilePhotosSection(
                      photos: profileSummary?.checkInPhotos ?? [],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Failed to load profile',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(profileViewModelProvider.notifier).loadProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
