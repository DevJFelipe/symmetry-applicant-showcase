import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Use case for retrieving the currently authenticated user.
class GetCurrentUserUseCase implements UseCase<UserEntity?, void> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<UserEntity?> call({void params}) {
    return _authRepository.getCurrentUser();
  }
}
