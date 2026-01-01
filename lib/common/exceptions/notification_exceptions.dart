/// 알림(FCM) 관련 최상위 예외
abstract class NotificationException implements Exception {
  final String message; // 개발자가 볼 상세 메시지 (한글)
  final String? code; // 원본 에러 코드 (디버깅용)

  NotificationException(this.message, {this.code});

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

class NotificationPermissionDeniedException extends NotificationException {
  NotificationPermissionDeniedException({String? message, String? code})
    : super(message ?? '알림 권한이 거부되었습니다. 설정에서 권한을 허용해야 합니다.', code: code);
}

class NotificationTokenFetchException extends NotificationException {
  NotificationTokenFetchException({String? message, String? code})
    : super(message ?? 'FCM 토큰을 발급받지 못했습니다.', code: code);
}

class NotificationTokenDeleteException extends NotificationException {
  NotificationTokenDeleteException({String? message, String? code})
    : super(message ?? '기존 FCM 토큰을 삭제하는 중 오류가 발생했습니다.', code: code);
}

class NotificationPlatformException extends NotificationException {
  NotificationPlatformException({String? message, String? code})
    : super(
        message ?? '현재 기기 환경(APNs/Play Services) 문제로 알림 서비스를 사용할 수 없습니다.',
        code: code,
      );
}

class NotificationNetworkException extends NotificationException {
  NotificationNetworkException({String? message, String? code})
    : super(message ?? '네트워크 연결이 불안정하여 알림 서버에 접근할 수 없습니다.', code: code);
}

class NotificationUnknownException extends NotificationException {
  NotificationUnknownException({required String message, String? code})
    : super(message, code: code);
}
