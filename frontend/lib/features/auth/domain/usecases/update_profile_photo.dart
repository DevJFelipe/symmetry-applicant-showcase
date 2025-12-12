import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/update_profile_photo_params.dart';

/// Use case for updating user's profile photo.
/// 
/// Handles uploading the new photo, deleting the previous one,
/// and updating the user's profile in Firebase Auth.
class UpdateProfilePhotoUseCase
    implements UseCase<UserEntity, UpdateProfilePhotoParams> {
  final AuthRepository _authRepository;

  UpdateProfilePhotoUseCase(this._authRepository);

  @override
  Future<UserEntity> call({UpdateProfilePhotoParams? params}) {
    return _authRepository.updateProfilePhoto(
      imageFile: params!.imageFile,
      userId: params.userId,
    );
  }
}
