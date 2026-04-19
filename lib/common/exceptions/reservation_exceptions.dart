import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 예약(DB) 관련 최상위 예외
sealed class ReservationException extends AppException {
  ReservationException(super.message, {super.code});

  @override
  String get title => switch (this) {
    // 1. 권한/보안
    ReservationPermissionDeniedException() => '권한이 없습니다',

    // 2. 데이터 존재 여부
    ReservationNotFoundException() => '예약을 찾을 수 없습니다',

    // 3. 네트워크/환경/리소스
    ReservationNetworkException() => '네트워크 에러가 발생했습니다',
    ReservationResourceExhaustedException() => '요청 한도가 초과되었습니다',

    // 4. 데이터 충돌/처리 실패/취소
    ReservationTransactionException() => '처리에 실패했습니다',
    ReservationCancelledException() => '작업이 취소되었습니다',

    // 5. 앱 버전/파싱 문제
    ReservationDataParsingException() => '데이터 형식이 일치하지 않습니다',

    // 6. 유효성 검사 / 알 수 없는 에러
    ReservationValidationException() ||
    ReservationUnknownException() => '에러가 발생했습니다',
  };

  @override
  String get content => switch (this) {
    // 1. 권한 부족
    ReservationPermissionDeniedException() =>
      '이 작업을 수행할 권한이 없습니다.\n개발자에게 문의하거나 다시 로그인해 주세요.',

    // 2. 데이터 상태
    ReservationNotFoundException() => '이미 삭제되었거나 존재하지 않는 예약입니다.',

    // 3. 네트워크 및 리소스 이슈
    ReservationNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    ReservationResourceExhaustedException() =>
      '잠시 후 다시 시도해 주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

    // 4. 처리 과정
    ReservationTransactionException() =>
      '일시적인 충돌이 발생했습니다.\n잠시 후 다시 시도해 주세요.',
    ReservationCancelledException() => '작업이 중단되었습니다.',

    // 5. 파싱 에러
    ReservationDataParsingException() =>
      '스토어에서 최신 버전으로 업데이트해주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

    // 6. 유효성 검사 / 알 수 없는 에러
    ReservationValidationException() ||
    ReservationUnknownException() => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
  };

  @override
  bool get isSilentable => switch (this) {
    ReservationCancelledException() => true,
    ReservationPermissionDeniedException() ||
    ReservationNotFoundException() ||
    ReservationNetworkException() ||
    ReservationResourceExhaustedException() ||
    ReservationTransactionException() ||
    ReservationDataParsingException() ||
    ReservationValidationException() ||
    ReservationUnknownException() => false,
  };
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

/// 예약 데이터에 접근할 권한이 없을 때 발생하는 예외
///
/// Firebase Code: `permission-denied`, `unauthenticated`
class ReservationPermissionDeniedException extends ReservationException {
  ReservationPermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

/// 요청한 예약(Document)을 찾을 수 없을 때 발생하는 예외
///
/// Firebase Code: `not-found`
class ReservationNotFoundException extends ReservationException {
  ReservationNotFoundException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 연결이 불안정하거나 끊겼을 때 발생하는 예외
///
/// Firebase Code: `unavailable`, `deadline-exceeded`
class ReservationNetworkException extends ReservationException {
  ReservationNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// 트랜잭션 처리 중 충돌이 발생했을 때 예외
///
/// Firebase Code: `aborted`, `failed-precondition`
class ReservationTransactionException extends ReservationException {
  ReservationTransactionException({required String message, String? code})
    : super(message, code: code);
}

/// DB 데이터와 앱의 예약 모델 구조가 일치하지 않을 때 발생하는 예외
class ReservationDataParsingException extends ReservationException {
  ReservationDataParsingException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 에러가 발생했을 때 사용하는 예외
class ReservationUnknownException extends ReservationException {
  ReservationUnknownException({required String message, String? code})
    : super(message, code: code);
}

/// 요청 한도(Quota)를 초과하거나 리소스가 부족할 때 발생하는 예외
///
/// Firebase Code: `resource-exhausted`
class ReservationResourceExhaustedException extends ReservationException {
  ReservationResourceExhaustedException({
    required String message,
    String? code,
  }) : super(message, code: code);
}

/// 작업이 취소되었을 때 발생하는 예외
///
/// Firebase Code: `cancelled`
class ReservationCancelledException extends ReservationException {
  ReservationCancelledException({
    String message = 'Operation cancelled',
    String? code,
  }) : super(message, code: code);
}

/// 예약 등록, 수정 시 형식에 맞지 않는 데이터가 있을 때 발생하는 예외
class ReservationValidationException extends ReservationException {
  ReservationValidationException({required String message, String? code})
    : super(message, code: code);
}
