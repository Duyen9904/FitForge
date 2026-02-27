import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

/// State for profile screen. Minimal for now; extend for edit mode, etc. later.
@freezed
class ProfileState with _$ProfileState {
  /// Initial state
  const factory ProfileState.initial() = ProfileStateInitial;

  /// Loading (e.g. during logout or future profile operations)
  const factory ProfileState.loading() = ProfileStateLoading;
}
