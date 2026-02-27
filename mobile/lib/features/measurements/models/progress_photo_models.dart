import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/date_utils.dart';

part 'progress_photo_models.freezed.dart';
part 'progress_photo_models.g.dart';

/// Progress photo response - matches backend ProgressPhotoResponse
@freezed
class ProgressPhotoResponse with _$ProgressPhotoResponse {
  const factory ProgressPhotoResponse({
    int? photoId,
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? photoDate,
    String? photoUrl,
    String? category,
    String? notes,
  }) = _ProgressPhotoResponse;

  factory ProgressPhotoResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgressPhotoResponseFromJson(json);
}

/// Request to upload a progress photo - matches backend UploadProgressPhotoRequest
@freezed
class UploadProgressPhotoRequest with _$UploadProgressPhotoRequest {
  const factory UploadProgressPhotoRequest({
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? photoDate,
    required String category,
    String? notes,
  }) = _UploadProgressPhotoRequest;

  factory UploadProgressPhotoRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadProgressPhotoRequestFromJson(json);
}
