import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps a widget in MaterialApp + Scaffold for simple widget tests.
Widget wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

/// Wraps a widget in ProviderScope + MaterialApp + Scaffold
/// for widgets that depend on Riverpod providers.
Widget wrapInProviderScope(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}
