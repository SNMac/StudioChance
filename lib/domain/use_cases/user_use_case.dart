import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/use_case_helpers.dart';

abstract interface class UserUseCase {
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
  });

  /// 내 점포 색상·점포 메모 수정 — 넘긴 값만 바꾼다
  Future<Either<Exception, void>> updateStoreInfo({
    required String uid,
    required String storeId,
    StoreColor? color,
    String? memo,
  });

  /// 내 점포 별명 저장. 비어 있으면 점포 별명을 지운다. 검증 규칙은 `normalizeStoreAlias`
  Future<Either<Exception, void>> updateStoreAlias({
    required String uid,
    required String storeId,
    required String alias,
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
  }) {
    return _repository.updateUser(uid: uid, email: email, nickname: nickname);
  }

  @override
  Future<Either<Exception, void>> updateStoreInfo({
    required String uid,
    required String storeId,
    StoreColor? color,
    String? memo,
  }) {
    return _repository.updateStoreInfo(
      uid: uid,
      storeId: storeId,
      color: color,
      memo: memo,
    );
  }

  @override
  Future<Either<Exception, void>> updateStoreAlias({
    required String uid,
    required String storeId,
    required String alias,
  }) {
    return getCurrentUserOrThrow(_repository)
        .flatMap(
          (currentUser) => TaskEither.fromEither(
            normalizeStoreAlias(
              alias,
              currentUser: currentUser,
              storeId: storeId,
            ),
          ),
        )
        .flatMap(
          (normalizedAlias) => TaskEither(
            () => _repository.updateStoreAlias(
              uid: uid,
              storeId: storeId,
              alias: normalizedAlias,
            ),
          ),
        )
        .run();
  }
}
