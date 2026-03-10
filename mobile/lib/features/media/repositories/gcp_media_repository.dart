import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums/media_category.dart';
import '../models/gcp_models.dart';
import '../services/gcp_media_service.dart';

final gcpMediaRepositoryProvider = Provider<GcpMediaRepository>((ref) {
  final service = ref.watch(gcpMediaServiceProvider);
  return GcpMediaRepository(service: service);
});

/// Repository for GCP media operations.
///
/// Wraps [GcpMediaService] with consistent error handling and
/// provides a clean API for viewmodels / other repositories.
class GcpMediaRepository {
  final GcpMediaService _service;

  GcpMediaRepository({required GcpMediaService service}) : _service = service;

  /// Upload a file and return the upload response.
  ///
  /// Throws on validation failure or network error.
  Future<MediaUploadResponse> uploadMedia(
    File file,
    MediaCategory category,
  ) async {
    return _service.uploadMedia(file, category);
  }

  /// Get a fresh signed URL for displaying a stored media file.
  ///
  /// Use this when a previously cached signedUrl has expired (60 min TTL).
  Future<String> getSignedUrl(String objectPath) async {
    return _service.getSignedUrl(objectPath);
  }

  /// Delete a media file from storage.
  Future<void> deleteMedia(String objectPath) async {
    return _service.deleteMedia(objectPath);
  }
}
