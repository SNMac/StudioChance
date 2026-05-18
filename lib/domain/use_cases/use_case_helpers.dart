import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

/// [UserRepository]에서 현재 로그인한 유저를 가져오는 [TaskEither].
/// 로그인 상태가 아니거나 유저 정보가 없으면 [AuthUserNotFoundException]을 반환.
TaskEither<Exception, User> getCurrentUserOrThrow(
  UserRepository userRepository,
) {
  return TaskEither.tryCatch(() async {
    final result = await userRepository.getCurrentUser();
    return result.fold((left) => throw left, (right) {
      if (right == null) {
        throw AuthUserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
      }
      return right;
    });
  }, (error, stackTrace) => error is Exception ? error : Exception(error));
}
