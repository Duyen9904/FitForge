import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/notification_model.dart';

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient: apiClient);
});

/// Service for notification API operations
class NotificationService {
  final ApiClient apiClient;

  NotificationService({required this.apiClient});

  /// Get paginated notifications, optionally filtered by read status.
  /// [isRead] null = all, true = read only, false = unread only
  Future<ApiResponse<List<NotificationModel>>> getNotifications({
    int page = 0,
    int size = 20,
    bool? isRead,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (isRead != null) {
      queryParams['isRead'] = isRead;
    }

    final response = await apiClient.get(
      ApiConstants.notifications,
      queryParameters: queryParams,
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final content = json as Map<String, dynamic>;
        final list = (content['content'] as List?)
                ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return list;
      },
    );
  }

  /// Get unread notification count
  Future<ApiResponse<int>> getUnreadCount() async {
    final response = await apiClient.get(ApiConstants.notificationsUnreadCount);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json as int,
    );
  }

  /// Mark a notification as read
  Future<ApiResponse<void>> markAsRead(int notificationId) async {
    final response = await apiClient.put(
      ApiConstants.notificationMarkRead(notificationId),
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }

  /// Mark all notifications as read
  Future<ApiResponse<int>> markAllAsRead() async {
    final response = await apiClient.put(ApiConstants.notificationsReadAll);

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json as int,
    );
  }

  /// Register device token for push notifications
  Future<ApiResponse<void>> registerDeviceToken({
    required String deviceToken,
    String? deviceType,
    String? deviceName,
  }) async {
    final response = await apiClient.post(
      ApiConstants.notificationDevices,
      data: {
        'deviceToken': deviceToken,
        if (deviceType != null) 'deviceType': deviceType,
        if (deviceName != null) 'deviceName': deviceName,
      },
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }

  /// Unregister device token (e.g., on logout)
  Future<ApiResponse<void>> unregisterDeviceToken(String token) async {
    final response = await apiClient.delete(
      ApiConstants.notificationDevices,
      queryParameters: {'token': token},
    );

    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (_) {},
    );
  }
}
