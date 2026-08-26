import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/repository_interfaces/notification_repository.dart';

abstract interface class NotificationUseCase {
  Future<Either<Exception, bool>> requestPermission();

  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  });

  Stream<String> get onTokenRefresh;

  Stream<PushMessage> get foregroundMessages;

  Stream<PushMessage> get openedAppMessages;

  Future<PushMessage?> getInitialMessage();

  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  });

  Future<Either<Exception, void>> showLocalNotification(PushMessage message);
}

/// 현재는 모든 메서드가 Repository로 단순 위임한다.
/// Presentation이 Repository를 직접 호출하지 않도록 계층을 유지하기 위함이며,
/// 알림 정책(예: 방해 금지 시간)이 생기면 이 계층에 추가한다. (CLAUDE.md D10)
class NotificationUseCaseImpl implements NotificationUseCase {
  final NotificationRepository _notificationRepository;

  NotificationUseCaseImpl({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Exception, bool>> requestPermission() =>
      _notificationRepository.requestPermission();

  @override
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  }) => _notificationRepository.registerFcmToken(uid: uid, token: token);

  @override
  Stream<String> get onTokenRefresh => _notificationRepository.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages =>
      _notificationRepository.foregroundMessages;

  @override
  Stream<PushMessage> get openedAppMessages =>
      _notificationRepository.openedAppMessages;

  @override
  Future<PushMessage?> getInitialMessage() =>
      _notificationRepository.getInitialMessage();

  @override
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  }) => _notificationRepository.initLocalNotifications(onTap: onTap);

  @override
  Future<Either<Exception, void>> showLocalNotification(PushMessage message) =>
      _notificationRepository.showLocalNotification(message);
}
