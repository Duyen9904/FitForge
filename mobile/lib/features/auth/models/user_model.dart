import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model - extended profile (for /users/me endpoint)
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int userId,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? fitnessLevel,
    @Default(false) bool isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
}

extension UserModelExtensions on UserModel {
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return username;
  }
  
  String get initials {
    if (firstName != null && lastName != null && 
        firstName!.isNotEmpty && lastName!.isNotEmpty) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }
}
