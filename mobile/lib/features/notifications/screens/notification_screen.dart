import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../viewmodels/notification_screen_viewmodel.dart';
import '../widgets/notification_tab_list.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationScreenViewModelProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationScreenViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              ref
                  .read(notificationScreenViewModelProvider.notifier)
                  .markAllAsRead();
            },
            icon: Icon(
              Icons.done_all_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey400,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.grey200.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Read'),
          ],
        ),
      ),
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        loaded: (all, unread, read, currentPage, hasMore, isLoadingMore) {
          return TabBarView(
            controller: _tabController,
            children: [
              // All tab — with pagination
              NotificationTabList(
                notifications: all,
                onRefresh: () => ref
                    .read(notificationScreenViewModelProvider.notifier)
                    .refresh(),
                onLoadMore: () => ref
                    .read(notificationScreenViewModelProvider.notifier)
                    .loadMore(),
                isLoadingMore: isLoadingMore,
                hasMore: hasMore,
                onNotificationTap: _onNotificationTap,
                emptyTitle: 'No notifications yet',
                emptySubtitle:
                    'When you receive notifications, they\'ll appear here.',
              ),

              // Unread tab
              NotificationTabList(
                notifications: unread,
                onRefresh: () => ref
                    .read(notificationScreenViewModelProvider.notifier)
                    .refresh(),
                onNotificationTap: _onNotificationTap,
                emptyTitle: 'All caught up!',
                emptySubtitle: 'You have no unread notifications.',
              ),

              // Read tab
              NotificationTabList(
                notifications: read,
                onRefresh: () => ref
                    .read(notificationScreenViewModelProvider.notifier)
                    .refresh(),
                onNotificationTap: _onNotificationTap,
                emptyTitle: 'No read notifications',
                emptySubtitle:
                    'Notifications you\'ve read will appear here.',
              ),
            ],
          );
        },
        error: (message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  'Failed to load notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing20),
                FilledButton(
                  onPressed: () => ref
                      .read(notificationScreenViewModelProvider.notifier)
                      .loadNotifications(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNotificationTap(int notificationId) {
    ref
        .read(notificationScreenViewModelProvider.notifier)
        .markAsRead(notificationId);
  }
}
