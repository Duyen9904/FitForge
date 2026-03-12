import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/notification_repository.dart';
import 'notification_screen_state.dart';

final notificationScreenViewModelProvider = StateNotifierProvider<
    NotificationScreenViewModel, NotificationScreenState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationScreenViewModel(repository: repository);
});

class NotificationScreenViewModel
    extends StateNotifier<NotificationScreenState> {
  final NotificationRepository _repository;

  NotificationScreenViewModel({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationScreenState.initial());

  /// Initial load for all tabs
  Future<void> loadNotifications() async {
    state = const NotificationScreenState.loading();
    try {
      final results = await Future.wait([
        _repository.fetchNotifications(page: 0, size: 20),
        _repository.fetchNotifications(page: 0, size: 100, isRead: false),
        _repository.fetchNotifications(page: 0, size: 100, isRead: true),
      ]);

      state = NotificationScreenState.loaded(
        allNotifications: results[0],
        unreadNotifications: results[1],
        readNotifications: results[2],
        currentPage: 0,
        hasMore: results[0].length >= 20,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load notifications',
        name: 'NotificationVM',
        error: e,
        stackTrace: stackTrace,
      );
      state = NotificationScreenState.error(e.toString());
    }
  }

  /// Load more notifications for the All tab (pagination)
  Future<void> loadMore() async {
    final current = state;
    if (current is! NotificationScreenLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    state = current.copyWith(isLoadingMore: true);
    try {
      final nextPage = current.currentPage + 1;
      final moreNotifications = await _repository.fetchNotifications(
        page: nextPage,
        size: 20,
      );

      state = current.copyWith(
        allNotifications: [
          ...current.allNotifications,
          ...moreNotifications,
        ],
        currentPage: nextPage,
        hasMore: moreNotifications.length >= 20,
        isLoadingMore: false,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load more notifications',
        name: 'NotificationVM',
        error: e,
        stackTrace: stackTrace,
      );
      state = current.copyWith(isLoadingMore: false);
    }
  }

  /// Pull-to-refresh — reload all tabs
  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _repository.fetchNotifications(page: 0, size: 20),
        _repository.fetchNotifications(page: 0, size: 100, isRead: false),
        _repository.fetchNotifications(page: 0, size: 100, isRead: true),
      ]);

      state = NotificationScreenState.loaded(
        allNotifications: results[0],
        unreadNotifications: results[1],
        readNotifications: results[2],
        currentPage: 0,
        hasMore: results[0].length >= 20,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to refresh notifications',
        name: 'NotificationVM',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      // Refresh to get updated lists
      await refresh();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark notification as read',
        name: 'NotificationVM',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      // Refresh to get updated lists
      await refresh();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark all notifications as read',
        name: 'NotificationVM',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
