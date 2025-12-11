import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/sign_in_params.dart';

/// Use case for signing in a user with email and password.
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<UserEntity> call({SignInParams? params}) {
    return _authRepository.signIn(
      email: params!.email,
      password: params.password,
    );
  }
}
