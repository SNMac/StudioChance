import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/notification_exceptions.dart';

part 'notification_data_source.g.dart';

abstract interface class NotificationDataSource {
  /// 토큰이 갱신되는 것을 감지하는 스트림
  Stream<String> get onTokenRefresh;

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
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

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
      final token = await _messaging.getToken();
      if (token == null) {
        throw NotificationPlatformException(
          message: 'FCM Token returned null (Platform issue)',
        );
      }
      return token;
    } catch (e) {
      throw _handleNotificationError(e);
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

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  Exception _handleNotificationError(Object e) {
    _logger.e('Notification Error', error: e);

    if (e is NotificationException) return e;

    if (e is FirebaseException) {
      final msg = e.message ?? 'Firebase Messaging Error';
      final code = e.code;

      switch (code) {
        case 'permission-blocked':
        case 'notifications-blocked':
          return NotificationPermissionDeniedException(
            message: msg,
            code: code,
          );

        case 'failed-precondition':
        case 'missing-dependencies':
          return NotificationPlatformException(message: msg, code: code);

        case 'network-request-failed':
        case 'unavailable':
          return NotificationNetworkException(message: msg, code: code);

        default:
          return NotificationUnknownException(message: msg, code: code);
      }
    }

    return NotificationUnknownException(message: e.toString());
  }
}

@Riverpod(keepAlive: true)
NotificationDataSource notificationDataSource(Ref ref) {
  return FirebaseMessagingDataSource(FirebaseMessaging.instance);
}
