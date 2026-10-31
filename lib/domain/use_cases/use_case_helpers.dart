import 'package:characters/characters.dart';
import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
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

/// [storeId] 점포에 붙일 점포 별명을 검증하고 저장할 값으로 바꾼다.
/// - 앞뒤 공백을 지운다. 비어 있으면 별명이 없다는 뜻이라 null을 돌려준다
/// - 입력 화면과 같이 글자(grapheme) 단위로 [maxStoreNameCharCount]자까지 받는다
/// - [currentUser]의 다른 점포(승인 대기 포함)의 화면 이름과 같으면 실패한다
Either<Exception, String?> normalizeStoreAlias(
  String alias, {
  required User currentUser,
  required String storeId,
}) {
  final trimmed = alias.trim();
  if (trimmed.isEmpty) return right(null);
  if (trimmed.characters.length > maxStoreNameCharCount) {
    return left(StoreAliasTooLongException(message: '점포 별명 길이 초과: $trimmed'));
  }
  if (currentUser.hasOtherStoreDisplayedAs(trimmed, exceptStoreId: storeId)) {
    return left(StoreAliasDuplicateException(message: '중복된 점포 별명: $trimmed'));
  }
  return right(trimmed);
}
