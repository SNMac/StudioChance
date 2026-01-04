/// 알림 관련 최상위 예외
abstract class NotificationException implements Exception {
  /// 개발자/로그용 원본 메시지
  final String message;

  /// 개발자/로그용 원본 에러 코드
  final String? code;

  NotificationException(this.message, {this.code});

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

class NotificationPermissionDeniedException extends NotificationException {
  NotificationPermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

class NotificationTokenFetchException extends NotificationException {
  NotificationTokenFetchException({required String message, String? code})
    : super(message, code: code);
}

class NotificationTokenDeleteException extends NotificationException {
  NotificationTokenDeleteException({required String message, String? code})
    : super(message, code: code);
}

class NotificationPlatformException extends NotificationException {
  NotificationPlatformException({required String message, String? code})
    : super(message, code: code);
}

class NotificationNetworkException extends NotificationException {
  NotificationNetworkException({required String message, String? code})
    : super(message, code: code);
}

class NotificationUnknownException extends NotificationException {
  NotificationUnknownException({required String message, String? code})
    : super(message, code: code);
}
