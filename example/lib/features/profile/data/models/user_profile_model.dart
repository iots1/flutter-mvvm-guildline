// features/profile/data/models/user_profile_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_profile_entity.dart'; // Implements Entity

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
abstract class UserProfileModel with _$UserProfileModel implements UserProfileEntity {
  const factory UserProfileModel({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'profile_picture_url') @Default('') String avatarUrl,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
}
