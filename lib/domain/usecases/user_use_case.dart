import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'user_use_case.g.dart';

abstract interface class UserUseCase {
  /// 현재 사용자 정보 반환
  Future<Either<Exception, User?>> getCurrentUser();

  /// 특정 사용자 정보 반환
  Future<Either<Exception, User?>> getUser(String uid);
}

class UserUseCaseImpl implements UserUseCase {
  final UserRepository _repository;

  const UserUseCaseImpl(this._repository);

  @override
  Future<Either<Exception, User?>> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  @override
  Future<Either<Exception, User?>> getUser(String uid) {
    return _repository.getUser(uid);
  }
}

@riverpod
UserUseCase userUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);

  return UserUseCaseImpl(repository);
}
