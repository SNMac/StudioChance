import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/local_notification_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/push_message_mapper.dart';
import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/repository_interfaces/notification_repository.dart';

part 'notification_repository_impl.g.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Logger _logger = Logger();

  final NotificationDataSource _notificationDataSource;
  final LocalNotificationDataSource _localNotificationDataSource;
  final UserDataSource _userDataSource;

  NotificationRepositoryImpl({
    required NotificationDataSource notificationDataSource,
    required LocalNotificationDataSource localNotificationDataSource,
    required UserDataSource userDataSource,
  }) : _notificationDataSource = notificationDataSource,
       _localNotificationDataSource = localNotificationDataSource,
       _userDataSource = userDataSource;

  @override
  Future<Either<Exception, bool>> requestPermission() async {
    try {
      final settings = await _notificationDataSource.requestPermission();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.i('알림 권한 요청 결과: ${settings.authorizationStatus}');
      return right(granted);
    } catch (e) {
      _logger.e('알림 권한 요청 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> enableForegroundPresentation() async {
    try {
      await _notificationDataSource.enableForegroundPresentation();
      return right(null);
    } catch (e) {
      _logger.e('포그라운드 알림 표시 설정 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  }) async {
    try {
      final resolvedToken =
          token ?? await _notificationDataSource.getFcmToken();
      await _userDataSource.addFcmToken(uid, resolvedToken);

      _logger.i('FCM 토큰 등록 완료\nuid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('FCM 토큰 등록 실패');
      return left(toException(e));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _notificationDataSource.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages =>
      _notificationDataSource.onMessage.map((message) => message.toEntity());

  @override
  Stream<PushMessage> get openedAppMessages => _notificationDataSource
      .onMessageOpenedApp
      .map((message) => message.toEntity());

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _notificationDataSource.getInitialMessage();
    return message?.toEntity();
  }

  @override
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  }) async {
    try {
      await _localNotificationDataSource.initialize(onTap: onTap);
      return right(null);
    } catch (e) {
      _logger.e('로컬 알림 초기화 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> showLocalNotification(
    PushMessage message,
  ) async {
    try {
      await _localNotificationDataSource.show(
        title: message.title ?? '알림',
        body: message.body ?? '',
        payload: jsonEncode(message.data),
      );
      return right(null);
    } catch (e) {
      _logger.e('로컬 알림 표시 실패');
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(
    notificationDataSource: ref.watch(notificationDataSourceProvider),
    localNotificationDataSource: ref.watch(localNotificationDataSourceProvider),
    userDataSource: ref.watch(userDataSourceProvider),
  );
}
