import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
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

  /// 내 점포 색상·점포 메모·점포 별명 수정 — 넘긴 값만 바꾼다
  /// - [alias]: 앞뒤 공백을 지우고 저장한다. 비어 있으면 점포 별명을 지운다.
  ///   내 다른 점포의 화면 이름과 같으면 실패한다 (`StoreAliasDuplicateException`)
  Future<Either<Exception, void>> updateStoreInfo({
    required String uid,
    required String storeId,
    String? alias,
    StoreColor? color,
    String? memo,
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
    String? alias,
    StoreColor? color,
    String? memo,
  }) {
    final trimmedAlias = alias?.trim();
    final TaskEither<Exception, void> validation =
        trimmedAlias == null || trimmedAlias.isEmpty
        ? TaskEither.right(null)
        : getCurrentUserOrThrow(_repository).flatMap(
            (currentUser) =>
                currentUser.hasOtherStoreDisplayedAs(
                  trimmedAlias,
                  exceptStoreId: storeId,
                )
                ? TaskEither.left(
                    StoreAliasDuplicateException(
                      message: '중복된 점포 별명: $trimmedAlias',
                    ),
                  )
                : TaskEither.right(null),
          );

    return validation
        .flatMap(
          (_) => TaskEither(
            () => _repository.updateStoreInfo(
              uid: uid,
              storeId: storeId,
              alias: trimmedAlias,
              color: color,
              memo: memo,
            ),
          ),
        )
        .run();
  }
}
