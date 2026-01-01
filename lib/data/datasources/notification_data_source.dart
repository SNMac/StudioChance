import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_data_source.g.dart';

abstract interface class NotificationDataSource {
  /// 알림 권한 요청
  Future<NotificationSettings> requestPermission();

  /// 현재 기기의 FCM 토큰 가져오기
  Future<String?> getFcmToken();

  /// 로그아웃 시 SDK 캐시 정리
  Future<void> deleteToken();
}

class FirebaseMessagingDataSource implements NotificationDataSource {
  final Logger _logger = Logger();
  final FirebaseMessaging _messaging;

  FirebaseMessagingDataSource(this._messaging);

  @override
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    _logger.d('알림 권한 상태: ${settings.authorizationStatus}');
    return settings;
  }

  @override
  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      _logger.w('FCM 토큰 획득 실패', error: e);
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      _logger.w('FCM 토큰 삭제 실패', error: e);
    }
  }
}

@Riverpod(keepAlive: true)
NotificationDataSource notificationDataSource(Ref ref) {
  return FirebaseMessagingDataSource(FirebaseMessaging.instance);
}
