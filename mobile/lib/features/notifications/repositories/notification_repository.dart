import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/push_notification_service.dart';
import '../services/notification_service.dart';

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final pushService = ref.watch(pushNotificationServiceProvider);
  return NotificationRepository(
    notificationService: notificationService,
    pushService: pushService,
  );
});

/// Orchestrates FCM token management with backend API
class NotificationRepository {
  final NotificationService notificationService;
  final PushNotificationService pushService;

  String? _currentToken;

  NotificationRepository({
    required this.notificationService,
    required this.pushService,
  });

  /// Initialize push notifications: get FCM token and register with backend
  Future<void> initializePushNotifications() async {
    try {
      // Initialize the push notification service (permissions, channels, listeners)
      await pushService.initialize();

      // Get FCM token and register with backend
      final token = await pushService.getToken();
      if (token != null) {
        _currentToken = token;
        await _registerTokenWithBackend(token);
      }

      // Listen for token refresh
      pushService.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        _registerTokenWithBackend(newToken);
      });

      developer.log('Push notifications initialized', name: 'NOTIFICATION');
    } catch (e) {
      developer.log('Failed to initialize push notifications: $e',
          name: 'NOTIFICATION');
    }
  }

  /// Unregister the current device token from the backend (e.g., on logout)
  Future<void> unregisterDevice() async {
    try {
      if (_currentToken != null) {
        await notificationService.unregisterDeviceToken(_currentToken!);
        developer.log('Device token unregistered', name: 'NOTIFICATION');
        _currentToken = null;
      }
    } catch (e) {
      developer.log('Failed to unregister device: $e', name: 'NOTIFICATION');
    }
  }

  /// Register token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await notificationService.registerDeviceToken(
        deviceToken: token,
        deviceType: pushService.deviceType,
      );
      developer.log('Device token registered with backend', name: 'NOTIFICATION');
    } catch (e) {
      developer.log('Failed to register token: $e', name: 'NOTIFICATION');
    }
  }
}
