import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/date_utils.dart';

part 'in_body_models.freezed.dart';
part 'in_body_models.g.dart';

/// Manual InBody import request - matches backend InBodyImportRequest
@freezed
class InBodyImportRequest with _$InBodyImportRequest {
  const factory InBodyImportRequest({
    @JsonKey(fromJson: parseDateTime, toJson: dateToIsoDateString)
    DateTime? testDate,
    double? weightKg,
    double? skeletalMuscleMass,
    double? bodyFatMass,
    double? bodyFatPercentage,
    double? bodyWaterLiters,
    int? basalMetabolicRate,
    int? visceralFatLevel,
    double? waistHipRatio,
    int? inBodyScore,
    String? notes,
  }) = _InBodyImportRequest;

  factory InBodyImportRequest.fromJson(Map<String, dynamic> json) =>
      _$InBodyImportRequestFromJson(json);
}
