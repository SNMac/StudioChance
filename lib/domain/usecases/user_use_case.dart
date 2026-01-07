import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'user_use_case.g.dart';

abstract interface class UserUseCase {
  /// 현재 로그인된 사용자 정보 반환
  /// - 로그인 상태가 아니거나 DB에 정보가 없으면 null 반환
  Future<Either<Exception, User?>> getCurrentUser();

  /// 특정 사용자 정보 반환
  Future<Either<Exception, User?>> getUser(String uid);

  /// 사용자 프로필 정보 업데이트
  /// - 온보딩이나 마이페이지에서 닉네임, 역할 등을 수정할 때 사용
  Future<Either<Exception, void>> updateUser({
    required String uid,
    String? email,
    String? nickname,
    UserRole? role,
  });

  /// 사용자의 소속 가게 ID 추가
  /// - 점포 생성 혹은 초대 수락 시 호출
  Future<Either<Exception, void>> addStoreId({
    required String uid,
    required String storeId,
  });

  /// 사용자의 소속 점포 ID 제거
  /// - 점포 삭제 혹은 점포 탈퇴 시 호출
  Future<Either<Exception, void>> removeStoreId({
    required String uid,
    required String storeId,
  });
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

  @override
  Future<Either<Exception, void>> addStoreId({
    required String uid,
    required String storeId,
  }) {
    return _repository.addStoreId(uid: uid, storeId: storeId);
  }

  @override
  Future<Either<Exception, void>> removeStoreId({
    required String uid,
    required String storeId,
  }) {
    return _repository.removeStoreId(uid: uid, storeId: storeId);
  }
}

@riverpod
UserUseCase userUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserUseCaseImpl(repository);
}
