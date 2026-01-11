/// 점포(DB) 관련 최상위 예외
abstract class StoreException implements Exception {
  /// 개발자/로그용 원본 메시지
  final String message;

  /// 개발자/로그용 원본 에러 코드
  final String? code;

  StoreException(this.message, {this.code});

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
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

/// 알 수 없는 오류가 발생했을 때 사용하는 예외
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

class StoreValidationException extends StoreException {
  StoreValidationException({required String message, String? code})
    : super(message, code: code);
}
