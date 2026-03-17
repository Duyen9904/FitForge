import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/models/user_model.dart';
import '../models/profile_models.dart';

part 'profile_state.freezed.dart';

/// State for the profile screen.
@freezed
class ProfileState with _$ProfileState {
  /// Initial state before any data is loaded
  const factory ProfileState.initial() = ProfileStateInitial;

  /// Loading user profile data
  const factory ProfileState.loading() = ProfileStateLoading;

  /// Profile data loaded successfully
  const factory ProfileState.loaded({
    required UserModel user,
    @Default(0) int achievementPoints,
    ProfileSummaryResponse? profileSummary,
    @Default(false) bool isUploadingAvatar,
  }) = ProfileStateLoaded;

  /// Error loading profile
  const factory ProfileState.error(String message) = ProfileStateError;
}
