import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/state/app_flow_state.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

/// Auth ViewModel Provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository, ref);
});

/// Current user email provider (for logout)
final currentUserEmailProvider = StateProvider<String?>((ref) => null);

/// ViewModel for authentication
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthViewModel(this._authRepository, this._ref) : super(const AuthState.initial());

  /// Get current user (UserModel) if authenticated
  UserModel? get currentUser {
    return state.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
  }

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      
      if (isAuthenticated) {
        // Check if token is expired
        final isExpired = await _authRepository.isTokenExpired();
        
        if (isExpired) {
          // Try to refresh
          final refreshed = await _authRepository.refreshToken();
          if (!refreshed) {
            state = const AuthState.unauthenticated();
            return;
          }
        }
        
        // Get current user profile
        final user = await _authRepository.getCurrentUser();
        
        // Load flow state BEFORE setting authenticated state to prevent router redirect to splash
        await _ref.read(appFlowStateProvider.notifier).checkFlowStatus(forceRefresh: true);
        
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } on NetworkException catch (e, stackTrace) {
      developer.log(
        'Check auth network error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error(
        'Unable to reach server. Please check your network connection.',
      );
    } on TimeoutException catch (e, stackTrace) {
      developer.log(
        'Check auth timeout error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error(
        'Connection timed out. The server might be offline.',
      );
    } on UnauthorizedException catch (e, stackTrace) {
      developer.log(
        'Check auth unauthorized',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.unauthenticated();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to check auth',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('connect') ||
          errorStr.contains('host')) {
        state = const AuthState.error(
          'Unable to reach server. Please check your network connection.',
        );
      } else {
        state = AuthState.error(e.toString());
      }
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    
    try {
      // Login and fetch full user profile
      await _authRepository.login(email, password);
      final user = await _authRepository.getCurrentUser();
      
      // Load flow state BEFORE setting authenticated state to prevent router redirect to splash
      await _ref.read(appFlowStateProvider.notifier).checkFlowStatus(forceRefresh: true);
      
      state = AuthState.authenticated(user);
    } on AuthException catch (e, stackTrace) {
      developer.log(
        'Login failed: ${e.message}',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
    } on ValidationException catch (e, stackTrace) {
      developer.log(
        'Login validation error: ${e.message}',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.message);
    } on UnauthorizedException catch (e, stackTrace) {
      developer.log(
        'Login unauthorized',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error('Invalid email or password');
    } on NetworkException catch (e, stackTrace) {
      developer.log(
        'Login network error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error('Network error. Please check your connection.');
    } catch (e, stackTrace) {
      developer.log(
        'Login unexpected error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.toString());
    }
  }

  /// Login with Google token
  Future<void> loginWithGoogle(String googleToken) async {
    state = const AuthState.loading();
    
    try {
      // Login with Google and fetch full user profile
      await _authRepository.loginWithGoogle(googleToken);
      final user = await _authRepository.getCurrentUser();
      
      // Load flow state BEFORE setting authenticated state to prevent router redirect to splash
      await _ref.read(appFlowStateProvider.notifier).checkFlowStatus(forceRefresh: true);
      
      state = AuthState.authenticated(user);
    } on AuthException catch (e, stackTrace) {
      developer.log(
        'Google login failed: ${e.message}',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
    } on NetworkException catch (e, stackTrace) {
      developer.log(
        'Google login network error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error('Network error. Please check your connection.');
    } catch (e, stackTrace) {
      developer.log(
        'Google login unexpected error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.toString());
    }
  }

  /// Register a new user
  /// Only requires core account fields. Profile data is collected during onboarding.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthState.loading();
    
    try {
      await _authRepository.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      state = const AuthState.registrationSuccess();
    } on AuthException catch (e, stackTrace) {
      developer.log(
        'Registration failed: ${e.message}',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
    } on ValidationException catch (e, stackTrace) {
      developer.log(
        'Registration validation error: ${e.message}',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.message);
    } on NetworkException catch (e, stackTrace) {
      developer.log(
        'Registration network error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error('Network error. Please check your connection.');
    } catch (e, stackTrace) {
      developer.log(
        'Registration unexpected error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.toString());
    }
  }

  /// Register with Google token
  Future<void> registerWithGoogle(String googleToken) async {
    state = const AuthState.loading();
    
    try {
      await _authRepository.registerWithGoogle(googleToken);
      state = const AuthState.registrationSuccess();
    } on AuthException catch (e, stackTrace) {
      developer.log(
        'Google registration failed: ${e.message}',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
    } on NetworkException catch (e, stackTrace) {
      developer.log(
        'Google registration network error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AuthState.error('Network error. Please check your connection.');
    } catch (e, stackTrace) {
      developer.log(
        'Google registration unexpected error',
        name: 'AuthViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.toString());
    }
  }

  /// Logout
  Future<void> logout(String email) async {
    state = const AuthState.loading();
    
    try {
      await _authRepository.logout(email);
      // Clear flow state on logout
      _ref.read(appFlowStateProvider.notifier).clear();
      // Clear current user email
      _ref.read(currentUserEmailProvider.notifier).state = null;
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  /// Clear error state
  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.unauthenticated();
    }
  }
}

