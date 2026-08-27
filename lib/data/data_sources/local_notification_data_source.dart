import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/notification_exceptions.dart';
import 'package:studio_chance/constants/notification_constants.dart';

part 'local_notification_data_source.g.dart';

abstract interface class LocalNotificationDataSource {
  /// 플러그인 초기화 및 Android 알림 채널 생성
  ///
  /// [onTap]에는 알림 탭 시 payload 문자열이 전달된다.
  Future<void> initialize({required void Function(String? payload) onTap});

  /// 즉시 알림 표시 (포그라운드 수신 시 사용)
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  });
}

class FlutterLocalNotificationDataSource
    implements LocalNotificationDataSource {
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _plugin;

  /// 알림마다 다른 ID를 부여해 이전 알림을 덮어쓰지 않도록 한다.
  int _nextNotificationId = 0;

  FlutterLocalNotificationDataSource(this._plugin);

  @override
  Future<void> initialize({
    required void Function(String? payload) onTap,
  }) async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // 권한 요청은 firebase_messaging의 requestPermission()이 담당하므로
      // 여기서는 중복 요청하지 않는다.
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (response) => onTap(response.payload),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              notificationChannelId,
              notificationChannelName,
              description: notificationChannelDescription,
              importance: Importance.high,
            ),
          );
    } catch (e) {
      _logger.e('로컬 알림 초기화 실패', error: e);
      throw NotificationConfigException(message: e.toString());
    }
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _plugin.show(
        id: _nextNotificationId++,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      _logger.e('로컬 알림 표시 실패', error: e);
      throw NotificationUnknownException(message: e.toString());
    }
  }
}

@Riverpod(keepAlive: true)
LocalNotificationDataSource localNotificationDataSource(Ref ref) {
  return FlutterLocalNotificationDataSource(FlutterLocalNotificationsPlugin());
}
