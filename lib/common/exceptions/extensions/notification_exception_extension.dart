import 'package:studio_chance/common/exceptions/notification_exceptions.dart';

extension NotificationExceptionExtension on NotificationException {
  /// 사용자에게 보여줄 제목
  String get title {
    return switch (this) {
      NotificationPermissionDeniedException() => '알림 권한이 없습니다',
      NotificationTokenFetchException() => '토큰 발급에 실패했습니다',
      NotificationTokenDeleteException() => '토큰 삭제에 실패했습니다',
      NotificationPlatformException() => '지원하지 않는 환경입니다',
      NotificationNetworkException() => '네트워크 오류가 발생했습니다',
      _ => '알림 설정에 오류가 발생했습니다',
    };
  }

  /// 사용자에게 보여줄 오류 내용
  String get content {
    return switch (this) {
      NotificationPermissionDeniedException() => '앱 설정에서 알림 권한을 허용해주세요.',

      NotificationTokenFetchException() => '잠시 후 다시 시도해주세요.',

      NotificationTokenDeleteException() => '알림 설정을 초기화 중 오류가 발생했습니다.',

      NotificationPlatformException() => 'Google Play 서비스 등 기기 환경을 확인해주세요.',

      NotificationNetworkException() => '네트워크 연결 상태를 확인하고 다시 시도해주세요.',

      _ => '잠시 후 다시 시도해주세요.',
    };
  }

  /// UI 표시 여부
  bool get isSilent {
    return switch (this) {
      _ => true,
    };
  }
}
