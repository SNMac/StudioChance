import 'package:studio_chance/common/exceptions/notification_exceptions.dart';

extension NotificationExceptionExtension on NotificationException {
  /// 사용자에게 보여줄 제목 (문장형 종결, 마침표 없음)
  String get title {
    return switch (this) {
      // 1. 권한/환경
      NotificationPermissionDeniedException() => '알림 권한이 없습니다',
      NotificationPlatformException() => '알림을 지원하지 않는 기기입니다',
      NotificationConfigException() => '앱 설정 오류가 발생했습니다',

      // 2. 네트워크/요청
      NotificationNetworkException() => '네트워크 오류가 발생했습니다',
      NotificationTooManyRequestsException() => '요청 횟수가 초과되었습니다',

      // 3. 토큰 처리
      NotificationTokenFetchException() ||
      NotificationTokenDeleteException() => '알림 설정에 실패했습니다',

      // 4. 기타
      _ => '알림 오류가 발생했습니다',
    };
  }

  /// 사용자에게 보여줄 오류 내용
  String get content {
    return switch (this) {
      // 1. 사용자가 해결 가능한 것
      NotificationPermissionDeniedException() =>
        '원활한 알림 수신을 위해 설정에서 권한을 허용해 주세요.',
      NotificationNetworkException() => '네트워크 연결 상태를 확인하고 다시 시도해 주세요.',
      NotificationTooManyRequestsException() => '잠시 후 다시 시도해 주세요.',

      // 2. 기기/환경 문제
      NotificationPlatformException() => 'Google Play 서비스가 없거나 지원하지 않는 기기입니다.',

      // 3. 내부/설정 문제
      NotificationConfigException() => '앱 설정에 문제가 발생했습니다.\n개발자에게 문의해주세요.',
      NotificationTokenFetchException() => '토큰을 가져오는데 실패했습니다.\n잠시 후 다시 시도해 주세요.',
      NotificationTokenDeleteException() => '알림 설정을 초기화하는 중 오류가 발생했습니다.',
      _ => '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
    };
  }

  /// UI 표시 여부
  /// - true: 사용자에게 알리지 않고(로그만 남기고) 넘어감
  /// - false: 사용자에게 다이얼로그나 스낵바로 알려야 함
  bool get isSilentable {
    return switch (this) {
      _ => true,
    };
  }
}
