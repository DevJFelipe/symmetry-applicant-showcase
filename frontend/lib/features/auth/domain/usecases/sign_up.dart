import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/sign_up_params.dart';

/// Use case for creating a new user account.
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<UserEntity> call({SignUpParams? params}) {
    return _authRepository.signUp(
      email: params!.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
