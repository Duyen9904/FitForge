import 'package:flutter/material.dart';
import '../../../ui/core/states/empty_screen.dart';

/// Empty state widget for notification tabs using [EmptyScreen]
class NotificationEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const NotificationEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyScreen(
      title: title,
      description: subtitle,
    );
  }
}
