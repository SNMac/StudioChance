import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'user_use_case.g.dart';

abstract interface class UserUseCase {
  /// 인증 정보를 바탕으로 유저 조회/생성
  /// AppAuthController에서 로그인 상태 분기 처리를 위해 사용됨
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo);

  /// 현재 로그인된 사용자 정보 반환
  /// - 로그인 상태가 아니거나 DB에 정보가 없으면 null 반환
  Future<Either<Exception, User?>> getCurrentUser();

  /// 특정 사용자 정보 반환
  Future<Either<Exception, User?>> getUser(String uid);

  /// 사용자 프로필 정보 업데이트
  Future<Either<Exception, void>> updateUser({
    required String uid,
    String? email,
    String? nickname,
    UserRole? role,
  });
}

class UserUseCaseImpl implements UserUseCase {
  final UserRepository _repository;

  const UserUseCaseImpl(this._repository);

  @override
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo) {
    return _repository.fetchOrCreateUser(authInfo);
  }

  @override
  Future<Either<Exception, User?>> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  @override
  Future<Either<Exception, User?>> getUser(String uid) {
    return _repository.getUser(uid);
  }

  @override
  Future<Either<Exception, void>> updateUser({
    required String uid,
    String? email,
    String? nickname,
    UserRole? role,
  }) {
    return _repository.updateUser(
      uid: uid,
      email: email,
      nickname: nickname,
      role: role,
    );
  }
}

@riverpod
UserUseCase userUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserUseCaseImpl(repository);
}
