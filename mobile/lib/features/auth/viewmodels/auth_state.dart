import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  /// Initial state before authentication check
  const factory AuthState.initial() = AuthStateInitial;

  /// Loading state during auth operations
  const factory AuthState.loading() = AuthStateLoading;

  /// User is authenticated with full profile
  const factory AuthState.authenticated(UserModel user) = AuthStateAuthenticated;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Registration successful (needs login)
  const factory AuthState.registrationSuccess() = AuthStateRegistrationSuccess;

  /// Authentication error occurred
  /// [fieldErrors] contains field-specific validation errors from the backend
  const factory AuthState.error(String message, {Map<String, List<String>>? fieldErrors}) = AuthStateError;
}
