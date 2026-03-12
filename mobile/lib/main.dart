import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for push notifications
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
  
  runApp(
    const ProviderScope(
      child: GymPlanApp(),
    ),
  );
}
