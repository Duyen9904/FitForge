import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Background message: ${message.notification?.title}',
    name: 'FCM_BG',
  );
}

/// Riverpod provider for PushNotificationService
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

/// Core push notification service wrapping Firebase Messaging
/// and flutter_local_notifications for foreground display.
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'gymplan_notifications',
    'GymPlan Notifications',
    description: 'Workout reminders & missed workout alerts',
    importance: Importance.high,
  );

  /// Initialize FCM permissions, local notification channel, and listeners
  Future<void> initialize() async {
    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    developer.log(
      'FCM permission: ${settings.authorizationStatus}',
      name: 'FCM',
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );
    await _localNotifications.initialize(initSettings);

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground message listener — show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check for initial message (app launched from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    developer.log('Push notification service initialized', name: 'FCM');
  }

  /// Get the current FCM device token
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      developer.log('FCM Token: $token', name: 'FCM');
      return token;
    } catch (e) {
      developer.log('Failed to get FCM token: $e', name: 'FCM');
      return null;
    }
  }

  /// Stream of token refresh events
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Get the device type string for backend registration
  String get deviceType {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return 'UNKNOWN';
  }

  // ============= Private Handlers =============

  void _handleForegroundMessage(RemoteMessage message) {
    developer.log(
      'Foreground message: ${message.notification?.title}',
      name: 'FCM',
    );

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    developer.log(
      'Notification tapped: ${message.data}',
      name: 'FCM',
    );
    // TODO: Navigate to relevant screen based on message.data
  }
}
