import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';

abstract interface class NotificationRepository {
  /// 알림 권한 요청
  /// - 허용됨(authorized/provisional)이면 `true`
  Future<Either<Exception, bool>> requestPermission();

  /// 현재 기기의 FCM 토큰을 `users/{uid}.fcmTokens`에 추가한다.
  /// - [token]이 null이면 SDK에서 현재 토큰을 조회한다.
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  });

  /// FCM 토큰 갱신 스트림
  Stream<String> get onTokenRefresh;

  /// 앱이 포그라운드일 때 수신한 메시지
  Stream<PushMessage> get foregroundMessages;

  /// 백그라운드에서 알림을 탭해 앱이 열린 경우의 메시지
  Stream<PushMessage> get openedAppMessages;

  /// 종료 상태에서 알림을 탭해 앱이 실행됐다면 그 메시지
  Future<PushMessage?> getInitialMessage();

  /// 로컬 알림 초기화 (Android 채널 생성 포함)
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  });

  /// 포그라운드 수신 메시지를 로컬 알림으로 표시한다.
  Future<Either<Exception, void>> showLocalNotification(PushMessage message);
}
