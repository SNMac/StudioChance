import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 알림 관련 최상위 예외
abstract class NotificationException extends AppException {
  NotificationException(super.message, {super.code});
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

/// 알림 권한이 차단되었거나 거부되었을 때 발생하는 예외
///
/// 사용자가 시스템 설정에서 알림을 껐거나, 권한 요청 팝업에서 거부를 누른 경우입니다.
/// Firebase Code: `permission-blocked`, `notifications-blocked`
class NotificationPermissionDeniedException extends NotificationException {
  NotificationPermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

/// FCM 토큰을 가져오는 데 실패했을 때 발생하는 예외
///
/// `getToken()` 메서드가 null을 반환하거나 내부 에러로 실패한 경우입니다.
class NotificationTokenFetchException extends NotificationException {
  NotificationTokenFetchException({required String message, String? code})
    : super(message, code: code);
}

/// FCM 토큰 삭제에 실패했을 때 발생하는 예외
///
/// 로그아웃 시 토큰 폐기(`deleteToken`) 과정에서 문제가 발생한 경우입니다.
class NotificationTokenDeleteException extends NotificationException {
  NotificationTokenDeleteException({required String message, String? code})
    : super(message, code: code);
}

/// 기기 환경 문제로 알림 기능을 사용할 수 없을 때 발생하는 예외
///
/// Google Play Services가 없거나(에뮬레이터 등), iOS APNs 인증서 설정이 누락된 경우입니다.
/// Firebase Code: `failed-precondition`, `missing-dependencies`, `operation-not-allowed`
class NotificationPlatformException extends NotificationException {
  NotificationPlatformException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 문제로 FCM 서버와 통신할 수 없을 때 발생하는 예외
///
/// Firebase Code: `network-request-failed`, `unavailable`
class NotificationNetworkException extends NotificationException {
  NotificationNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 알림 에러
class NotificationUnknownException extends NotificationException {
  NotificationUnknownException({required String message, String? code})
    : super(message, code: code);
}

/// 앱 설정(Configuration) 에러로 인해 발생하는 예외
///
/// `google-services.json` 파일이 누락되었거나 프로젝트 설정이 잘못된 경우 발생합니다.
/// Firebase Code: `no-app`, `invalid-options`
class NotificationConfigException extends NotificationException {
  NotificationConfigException({required String message, String? code})
    : super(message, code: code);
}

/// 너무 많은 요청을 보내 서버에서 차단했을 때 발생하는 예외
///
/// 짧은 시간에 토큰 요청을 과도하게 반복했을 때 발생합니다.
/// Firebase Code: `too-many-requests`
class NotificationTooManyRequestsException extends NotificationException {
  NotificationTooManyRequestsException({required String message, String? code})
    : super(message, code: code);
}
