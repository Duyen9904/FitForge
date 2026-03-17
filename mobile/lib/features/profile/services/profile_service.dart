import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../auth/models/user_model.dart';
import '../models/profile_models.dart';

/// Allowed image MIME types for uploads.
const _allowedImageTypes = {'image/jpeg', 'image/png', 'image/webp'};

/// Max image size: 10 MB.
const _maxImageSize = 10 * 1024 * 1024;

/// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileService(apiClient: apiClient);
});

/// Service for profile-related API operations.
class ProfileService {
  final ApiClient apiClient;

  ProfileService({required this.apiClient});

  /// Upload a new avatar image for the current user.
  ///
  /// Validates file type and size, then sends a multipart PUT request.
  /// Returns the updated [UserModel] with a signed `profileImageUrl`.
  Future<UserModel> uploadAvatar(File imageFile) async {
    // Client-side validation
    final fileSize = await imageFile.length();
    if (fileSize == 0) {
      throw ValidationException(message: 'File is empty');
    }
    if (fileSize > _maxImageSize) {
      throw ValidationException(
        message:
            'Image size ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB '
            'exceeds max 10 MB',
      );
    }
    final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
    if (!_allowedImageTypes.contains(mimeType)) {
      throw ValidationException(
        message: 'Unsupported file type: $mimeType. '
            'Allowed: JPEG, PNG, WebP',
      );
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(mimeType),
      ),
    });

    final response = await apiClient.put(
      ApiConstants.userAvatar,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return UserModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException(message: 'Invalid response format');
  }

  /// Get achievement points for the current user.
  Future<int> getAchievementPoints() async {
    final response = await apiClient.get(ApiConstants.achievements);
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as int? ?? 0;
    }
    return 0;
  }

  /// Get unified profile summary: activity heatmap + check-in photos.
  Future<ProfileSummaryResponse> getProfileSummary({int months = 6}) async {
    final response = await apiClient.get(
      ApiConstants.workoutProfileSummary,
      queryParameters: {'months': months},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return ProfileSummaryResponse.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    return const ProfileSummaryResponse();
  }

  /// Get user preferences.
  Future<Map<String, dynamic>> getUserPreferences() async {
    final response = await apiClient.get(ApiConstants.userPreferences);
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return {};
  }

  /// Update user preferences.
  Future<Map<String, dynamic>> updateUserPreferences(
      Map<String, dynamic> preferences) async {
    final response =
        await apiClient.put(ApiConstants.userPreferences, data: preferences);
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return {};
  }
}
