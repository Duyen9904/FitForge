import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../shared/enums/media_category.dart';
import '../models/gcp_models.dart';

final gcpMediaServiceProvider = Provider<GcpMediaService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GcpMediaService(apiClient: apiClient);
});

/// Service for GCP Cloud Storage media operations.
///
/// Handles file upload, signed URL retrieval, and deletion.
/// The GCP endpoints live at /api/gcp/* (outside /api/v1),
/// so we construct full URLs manually.
class GcpMediaService {
  final ApiClient apiClient;

  /// Allowed image MIME types.
  static const _allowedImageTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  /// Allowed video MIME types.
  static const _allowedVideoTypes = {
    'video/mp4',
    'video/quicktime',
  };

  /// Max image size: 10 MB.
  static const _maxImageSize = 10 * 1024 * 1024;

  /// Max video size: 100 MB.
  static const _maxVideoSize = 100 * 1024 * 1024;

  GcpMediaService({required this.apiClient});

  /// Upload a file to GCP Cloud Storage.
  ///
  /// Validates file type, size, and category constraints before uploading.
  /// Returns [MediaUploadResponse] with objectPath and a temporary signedUrl.
  Future<MediaUploadResponse> uploadMedia(
    File file,
    MediaCategory category,
  ) async {
    // --- Client-side validation ---
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw ValidationException(message: 'File is empty');
    }

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final isImage = _allowedImageTypes.contains(mimeType);
    final isVideo = _allowedVideoTypes.contains(mimeType);

    if (!isImage && !isVideo) {
      throw ValidationException(
        message: 'Unsupported file type: $mimeType',
      );
    }

    if (isVideo && category != MediaCategory.exerciseVideo) {
      throw ValidationException(
        message: 'Video files are only allowed for video categories',
      );
    }

    if (isImage && fileSize > _maxImageSize) {
      throw ValidationException(
        message:
            'Image size ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB '
            'exceeds max 10 MB',
      );
    }

    if (isVideo && fileSize > _maxVideoSize) {
      throw ValidationException(
        message:
            'Video size ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB '
            'exceeds max 100 MB',
      );
    }

    // --- Build multipart request ---
    final formData = FormData.fromMap({
      'category': category.value,
      'file': await MultipartFile.fromFile(
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    });

    try {
      final response = await apiClient.dio.post(
        ApiConstants.gcpUpload,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return MediaUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a fresh signed URL for an existing object.
  ///
  /// Returns the signed URL as a plain string.
  Future<String> getSignedUrl(String objectPath) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.gcpSignedUrl,
        queryParameters: {'objectPath': objectPath},
        options: Options(responseType: ResponseType.plain),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a media file from GCP Cloud Storage.
  Future<void> deleteMedia(String objectPath) async {
    try {
      await apiClient.dio.delete(
        ApiConstants.gcpDelete,
        queryParameters: {'objectPath': objectPath},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response?.data is Map) {
      final msg = (e.response!.data as Map)['message'] ?? 'Upload failed';
      return ApiException(
        message: msg.toString(),
        statusCode: e.response?.statusCode,
      );
    }
    return ApiException(
      message: e.message ?? 'Network error during media operation',
    );
  }
}
