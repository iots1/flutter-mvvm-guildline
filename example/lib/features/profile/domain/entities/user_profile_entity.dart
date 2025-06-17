// features/profile/domain/entities/user_profile_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
abstract class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String name,
    required String email,
    @Default('') String avatarUrl,
  }) = _UserProfileEntity;
}
