import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 공휴일 달력(DB) 관련 최상위 예외
///
/// 공휴일 달력을 읽지 못해도 예약은 평일 요금으로 계산되므로(ADR-0002) 사용자에게
/// 다이얼로그로 알리지 않고, 화면은 가격 근처의 안내 문구로만 드러낸다.
sealed class HolidayException extends AppException {
  HolidayException(super.message, {super.code});

  @override
  String get title => switch (this) {
    HolidayPermissionDeniedException() => '권한이 없습니다',
    HolidayNetworkException() => '네트워크 에러가 발생했습니다',
    HolidayDataParsingException() => '데이터 형식이 일치하지 않습니다',
    HolidayUnknownException() => '에러가 발생했습니다',
  };

  @override
  String get content => switch (this) {
    HolidayPermissionDeniedException() => '공휴일 정보를 읽을 권한이 없습니다.',
    HolidayNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    HolidayDataParsingException() =>
      '스토어에서 최신 버전으로 업데이트해주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',
    HolidayUnknownException() => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
  };

  @override
  bool get isSilentable => true;
}

/// 공휴일 달력을 읽을 권한이 없을 때 발생하는 예외
///
/// Firebase Code: `permission-denied`, `unauthenticated`
class HolidayPermissionDeniedException extends HolidayException {
  HolidayPermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 연결이 불안정하거나 끊겼을 때 발생하는 예외
///
/// Firebase Code: `unavailable`, `deadline-exceeded`
class HolidayNetworkException extends HolidayException {
  HolidayNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// DB 데이터와 앱의 공휴일 모델 구조가 일치하지 않을 때 발생하는 예외
class HolidayDataParsingException extends HolidayException {
  HolidayDataParsingException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 에러가 발생했을 때 사용하는 예외
class HolidayUnknownException extends HolidayException {
  HolidayUnknownException({required String message, String? code})
    : super(message, code: code);
}
