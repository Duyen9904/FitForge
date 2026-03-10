import 'package:freezed_annotation/freezed_annotation.dart';

part 'gcp_models.freezed.dart';
part 'gcp_models.g.dart';

/// Response from POST /api/gcp/upload
@freezed
class MediaUploadResponse with _$MediaUploadResponse {
  const factory MediaUploadResponse({
    required String objectPath,
    required String signedUrl,
    required String contentType,
    required int fileSizeBytes,
  }) = _MediaUploadResponse;

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$MediaUploadResponseFromJson(json);
}
