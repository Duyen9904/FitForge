import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification model matching backend NotificationResponse DTO
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int notificationId,
    required String notificationType,
    required String title,
    required String message,
    String? data,
    @Default(false) bool isRead,
    @Default(false) bool isActedUpon,
    required String createdAt,
    String? scheduledFor,
    int? referenceId,
    String? referenceType,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
