/// 사용자(DB) 관련 최상위 예외
abstract class UserException implements Exception {
  /// 개발자/로그용 원본 메시지
  final String message;

  /// 개발자/로그용 원본 에러 코드
  final String? code;

  UserException(this.message, {this.code});

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

/// 데이터에 접근할 권한이 없을 때 발생하는 예외
///
/// Firestore Security Rules에 위배되거나, 인증되지 않은 사용자(`unauthenticated`)가
/// 보호된 데이터에 접근하려 할 때 발생합니다.
/// Firebase Code: `permission-denied`, `unauthenticated`
class UserPermissionDeniedException extends UserException {
  UserPermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

/// 요청한 문서(Document)를 찾을 수 없을 때 발생하는 예외
///
/// 이미 삭제된 데이터에 접근하거나, 잘못된 경로(ID)로 업데이트/삭제를 시도할 때 발생합니다.
/// Firebase Code: `not-found`
class UserNotFoundException extends UserException {
  UserNotFoundException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 연결이 불안정하거나 끊겼을 때 발생하는 예외
///
/// 오프라인 상태이거나, 요청 시간이 초과(`deadline-exceeded`)되었을 때 발생합니다.
/// Firebase Code: `unavailable`, `deadline-exceeded`, `network-request-failed`
class UserNetworkException extends UserException {
  UserNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// 트랜잭션 처리 중 충돌이 발생했을 때 예외
///
/// 동시에 여러 기기에서 같은 데이터를 수정하여 경합(Contention)이 발생했거나,
/// 트랜잭션 전제 조건이 실패했을 때 발생합니다.
/// Firebase Code: `aborted`, `failed-precondition`
class UserTransactionException extends UserException {
  UserTransactionException({required String message, String? code})
    : super(message, code: code);
}

/// DB 데이터와 앱의 모델(Model) 구조가 일치하지 않을 때 발생하는 예외
///
/// 주로 DB 스키마는 변경되었으나 앱이 구버전일 때 `fromJson` 과정에서 발생합니다.
/// Firebase Code: 없음 (Dart 내부 `TypeError`, `FormatException`)
class UserDataParsingException extends UserException {
  UserDataParsingException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 오류가 발생했을 때 사용하는 예외
///
/// 정의되지 않은 에러 코드나 시스템 내부 오류(`internal`) 등을 포괄합니다.
class UserUnknownException extends UserException {
  UserUnknownException({required String message, String? code})
    : super(message, code: code);
}

/// 이미 존재하는 데이터를 생성하려 할 때 발생하는 예외
///
/// 고유해야 하는 ID로 문서를 생성하려는데 이미 해당 문서가 있을 때 발생합니다.
/// Firebase Code: `already-exists`
class UserAlreadyExistsException extends UserException {
  UserAlreadyExistsException({required String message, String? code})
    : super(message, code: code);
}

/// 요청 한도(Quota)를 초과하거나 리소스가 부족할 때 발생하는 예외
///
/// Firestore 무료 사용량을 초과했거나, 단일 문서 크기 제한(1MB)을 넘었을 때 발생합니다.
/// Firebase Code: `resource-exhausted`
class UserResourceExhaustedException extends UserException {
  UserResourceExhaustedException({required String message, String? code})
    : super(message, code: code);
}

/// 작업이 취소되었을 때 발생하는 예외
///
/// 사용자가 로딩 중 취소하거나, 시스템에 의해 작업이 중단된 경우입니다.
/// Firebase Code: `cancelled`
class UserCancelledException extends UserException {
  UserCancelledException({String message = 'Operation cancelled', String? code})
    : super(message, code: code);
}
