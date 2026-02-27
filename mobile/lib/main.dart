import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
