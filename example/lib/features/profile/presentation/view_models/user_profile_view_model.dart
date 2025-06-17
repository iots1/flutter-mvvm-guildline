// features/profile/presentation/view_models/user_profile_view_model.dart
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
// import '../../domain/usecases/update_user_profile_usecase.dart'; // Uncomment in real app

class UserProfileViewModel extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  // final UpdateUserProfileUseCase updateUserProfileUseCase; // Uncomment in real app

  UserProfileViewModel({required this.getUserProfileUseCase /*, required this.updateUserProfileUseCase*/});

  UserProfileEntity? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileEntity? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getUserProfileUseCase.call(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (profile) {
        _userProfile = profile;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Example for update logic (needs UpdateUserProfileUseCase uncommented)
  // Future<void> updateProfile(UserProfileEntity updatedProfile) async {
  //   // ... logic to call updateUserProfileUseCase
  //   notifyListeners();
  // }
}
