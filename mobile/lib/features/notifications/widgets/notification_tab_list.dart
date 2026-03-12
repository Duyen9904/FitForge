import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/notification_model.dart';
import 'notification_card.dart';
import 'notification_empty_state.dart';

/// Reusable notification list for each tab, with pull-to-refresh
/// and optional infinite scroll support.
class NotificationTabList extends StatefulWidget {
  final List<NotificationModel> notifications;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final void Function(int notificationId)? onNotificationTap;
  final String emptyTitle;
  final String emptySubtitle;

  const NotificationTabList({
    super.key,
    required this.notifications,
    required this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onNotificationTap,
    this.emptyTitle = 'No notifications',
    this.emptySubtitle = 'You\'re all caught up!',
  });

  @override
  State<NotificationTabList> createState() => _NotificationTabListState();
}

class _NotificationTabListState extends State<NotificationTabList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.onLoadMore != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!widget.isLoadingMore && widget.hasMore) {
        widget.onLoadMore?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: AppColors.primary,
        child: Stack(
          children: [
            // Need a scrollable widget for RefreshIndicator to work on empty
            ListView(),
            NotificationEmptyState(
              title: widget.emptyTitle,
              subtitle: widget.emptySubtitle,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.notifications.length + (widget.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator at the bottom
          if (index == widget.notifications.length) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final notification = widget.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () {
              widget.onNotificationTap?.call(notification.notificationId);
            },
          );
        },
      ),
    );
  }
}
