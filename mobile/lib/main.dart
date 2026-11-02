import 'dart:developer' as developer;
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for push notifications
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Print FCM token
    final token = await FirebaseMessaging.instance.getToken();
    developer.log('FCM Token: $token', name: 'FCM');
    debugPrint('🔑 FCM Token: $token');
  } catch (e) {
    developer.log('Firebase init failed: $e', name: 'FIREBASE');
  }
  
  // Global error handler for uncaught exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      'Flutter Error',
      name: 'FLUTTER_ERROR',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };
  
  const enablePreview = bool.fromEnvironment('DEVICE_PREVIEW', defaultValue: false);

  runApp(
    DevicePreview(
      enabled: enablePreview,
      builder: (context) => const ProviderScope(
        child: GymPlanApp(),
      ),
    ),
  );
}
