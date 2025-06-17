// features/profile/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile_entity.dart';
// import '../repositories/user_profile_repository.dart'; // Uncomment in real app

class GetUserProfileUseCase {
  // final UserProfileRepository repository;
  // GetUserProfileUseCase({required this.repository});

  Future<Either<Failure, UserProfileEntity>> call(String userId) async {
    // Example: Call repository, get actual data
    await Future.delayed(const Duration(seconds: 1));
    if (userId == 'test_user_id') {
      return Right(UserProfileEntity(id: userId, name: 'Sample User', email: 'user@example.com', avatarUrl: 'https://i.pravatar.cc/150'));
    } else {
      return const Left(GeneralFailure(message: 'User not found'));
    }
  }
}
