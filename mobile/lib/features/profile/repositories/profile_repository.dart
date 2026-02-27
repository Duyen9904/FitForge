import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/auth_repository.dart';

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ProfileRepository(authRepository: authRepository);
});

/// Repository for profile data. Delegates to auth for current user; extend for profile-specific API later.
class ProfileRepository {
  final AuthRepository _authRepository;

  ProfileRepository({required AuthRepository authRepository})
      : _authRepository = authRepository;

  /// Get current user profile (delegates to auth). For future use when profile screen loads its own data.
  Future<UserModel> getCurrentUser() async {
    return _authRepository.getCurrentUser();
  }
}
