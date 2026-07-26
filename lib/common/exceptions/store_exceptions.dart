import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 점포(DB) 관련 최상위 예외
sealed class StoreException extends AppException {
  StoreException(super.message, {super.code});

  @override
  String get title => switch (this) {
    // 1. 권한/보안
    StorePermissionDeniedException() => '권한이 없습니다',

    // 2. 데이터 존재 여부
    StoreNotFoundException() => '점포를 찾을 수 없습니다',
    StoreAlreadyExistsException() => '이미 등록된 점포입니다',

    // 3. 네트워크/환경/리소스
    StoreNetworkException() => '네트워크 에러가 발생했습니다',
    StoreResourceExhaustedException() => '요청 한도가 초과되었습니다',

    // 4. 데이터 충돌/처리 실패/취소
    StoreTransactionException() => '처리에 실패했습니다',
    StoreCancelledException() => '작업이 취소되었습니다',

    // 5. 앱 버전/파싱 문제
    StoreDataParsingException() => '데이터 형식이 일치하지 않습니다',

    // 7. 중복 검증
    StoreNameDuplicateException() => '이미 사용 중인 점포명입니다',
    SpaceNameDuplicateException() => '중복된 공간명이 있습니다',

    // 6. 유효성 검사 / 알 수 없는 에러
    StoreValidationException() ||
    StoreUnknownException() => '에러가 발생했습니다',
  };

  @override
  String get content => switch (this) {
    // 1. 권한 부족
    StorePermissionDeniedException() =>
      '이 작업을 수행할 권한이 없습니다.\n개발자에게 문의하거나 다시 로그인해 주세요.',

    // 2. 데이터 상태
    StoreNotFoundException() => '이미 삭제되었거나 존재하지 않는 점포입니다.',
    StoreAlreadyExistsException() => '이미 등록된 점포 정보입니다.',

    // 3. 네트워크 및 리소스 이슈
    StoreNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    StoreResourceExhaustedException() =>
      '잠시 후 다시 시도해 주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

    // 4. 처리 과정
    StoreTransactionException() => '일시적인 충돌이 발생했습니다.\n잠시 후 다시 시도해 주세요.',
    StoreCancelledException() => '작업이 중단되었습니다.',

    // 5. 파싱 에러
    StoreDataParsingException() =>
      '스토어에서 최신 버전으로 업데이트해주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

    // 7. 중복 검증
    StoreNameDuplicateException() =>
      '이미 보유하신 다른 점포와 이름이 같습니다.\n다른 점포명으로 입력해 주세요.',
    SpaceNameDuplicateException() =>
      '같은 점포 안에서는 공간명을 중복해서 사용할 수 없습니다.\n공간명을 다르게 입력해 주세요.',

    // 6. 유효성 검사 / 알 수 없는 에러
    StoreValidationException() ||
    StoreUnknownException() => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
  };

  @override
  bool get isSilentable => switch (this) {
    StoreCancelledException() => true,
    StorePermissionDeniedException() ||
    StoreNotFoundException() ||
    StoreAlreadyExistsException() ||
    StoreNetworkException() ||
    StoreResourceExhaustedException() ||
    StoreTransactionException() ||
    StoreDataParsingException() ||
    StoreValidationException() ||
    StoreNameDuplicateException() ||
    SpaceNameDuplicateException() ||
    StoreUnknownException() => false,
  };
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

/// 점포 데이터에 접근할 권한이 없을 때 발생하는 예외
///
/// 관리자 권한이 없거나, 소속되지 않은 점포의 데이터를 수정하려 할 때 발생합니다.
/// Firebase Code: `permission-denied`, `unauthenticated`
class StorePermissionDeniedException extends StoreException {
  StorePermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

/// 요청한 점포(Document)를 찾을 수 없을 때 발생하는 예외
///
/// 삭제된 점포에 접근하거나, 잘못된 점포 ID로 조회를 시도할 때 발생합니다.
/// Firebase Code: `not-found`
class StoreNotFoundException extends StoreException {
  StoreNotFoundException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 연결이 불안정하거나 끊겼을 때 발생하는 예외
///
/// Firebase Code: `unavailable`, `deadline-exceeded`, `network-request-failed`
class StoreNetworkException extends StoreException {
  StoreNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// 트랜잭션 처리 중 충돌이 발생했을 때 예외
///
/// 동시에 여러 관리자가 같은 점포 설정을 수정하여 경합이 발생했을 때 주로 나타납니다.
/// Firebase Code: `aborted`, `failed-precondition`
class StoreTransactionException extends StoreException {
  StoreTransactionException({required String message, String? code})
    : super(message, code: code);
}

/// DB 데이터와 앱의 점포 모델(Model) 구조가 일치하지 않을 때 발생하는 예외
///
/// 점포 설정 필드가 추가/변경되었으나 앱이 구버전일 때 발생합니다.
class StoreDataParsingException extends StoreException {
  StoreDataParsingException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 에러가 발생했을 때 사용하는 예외
class StoreUnknownException extends StoreException {
  StoreUnknownException({required String message, String? code})
    : super(message, code: code);
}

/// 이미 존재하는 점포를 생성하려 할 때 발생하는 예외
///
/// Firebase Code: `already-exists`
class StoreAlreadyExistsException extends StoreException {
  StoreAlreadyExistsException({required String message, String? code})
    : super(message, code: code);
}

/// 요청 한도(Quota)를 초과하거나 리소스가 부족할 때 발생하는 예외
///
/// Firebase Code: `resource-exhausted`
class StoreResourceExhaustedException extends StoreException {
  StoreResourceExhaustedException({required String message, String? code})
    : super(message, code: code);
}

/// 작업이 취소되었을 때 발생하는 예외
///
/// Firebase Code: `cancelled`
class StoreCancelledException extends StoreException {
  StoreCancelledException({
    String message = 'Operation cancelled',
    String? code,
  }) : super(message, code: code);
}

/// 점포 등록, 수정 시 형식에 맞지 않는 데이터가 있을 때 발생하는 예외
class StoreValidationException extends StoreException {
  StoreValidationException({required String message, String? code})
    : super(message, code: code);
}

/// 이미 보유한 다른 점포와 이름이 중복될 때 발생하는 예외
class StoreNameDuplicateException extends StoreException {
  StoreNameDuplicateException({required String message, String? code})
    : super(message, code: code);
}

/// 같은 점포 내에서 공간명이 중복될 때 발생하는 예외
class SpaceNameDuplicateException extends StoreException {
  SpaceNameDuplicateException({required String message, String? code})
    : super(message, code: code);
}
