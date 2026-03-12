import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/notification_model.dart';

part 'notification_screen_state.freezed.dart';

/// State for the notification screen
@freezed
class NotificationScreenState with _$NotificationScreenState {
  const factory NotificationScreenState.initial() = NotificationScreenInitial;
  const factory NotificationScreenState.loading() = NotificationScreenLoading;
  const factory NotificationScreenState.loaded({
    required List<NotificationModel> allNotifications,
    required List<NotificationModel> unreadNotifications,
    required List<NotificationModel> readNotifications,
    @Default(0) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = NotificationScreenLoaded;
  const factory NotificationScreenState.error(String message) =
      NotificationScreenError;
}
