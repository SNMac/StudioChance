import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case.dart';

/// 호출을 기록하고 스트림 이벤트를 흉내낼 수 있는 [NotificationUseCase] fake.
///
/// 모든 메서드는 즉시 성공한다. 특정 메서드의 타이밍을 바꿔야 하는 테스트는
/// 상속해서 해당 메서드만 override한다.
class FakeNotificationUseCase implements NotificationUseCase {
  final _tokenController = StreamController<String>.broadcast();
  final _foregroundController = StreamController<PushMessage>.broadcast();
  final _openedAppController = StreamController<PushMessage>.broadcast();

  int requestPermissionCallCount = 0;
  int enableForegroundPresentationCallCount = 0;

  /// (uid, token) — token은 초기 등록이면 null.
  final List<(String uid, String? token)> registerFcmTokenCalls = [];
  final List<PushMessage> shownLocalNotifications = [];

  /// 토큰 갱신을 흉내낸다. 살아남은 구독이 어느 계정의 것인지 확인할 때 쓴다.
  void emitTokenRefresh(String token) => _tokenController.add(token);

  void emitForegroundMessage(PushMessage message) =>
      _foregroundController.add(message);

  Future<void> dispose() async {
    await _tokenController.close();
    await _foregroundController.close();
    await _openedAppController.close();
  }

  @override
  Future<Either<Exception, bool>> requestPermission() async {
    requestPermissionCallCount++;
    return right(true);
  }

  @override
  Future<Either<Exception, void>> enableForegroundPresentation() async {
    enableForegroundPresentationCallCount++;
    return right(null);
  }

  @override
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  }) async {
    registerFcmTokenCalls.add((uid, token));
    return right(null);
  }

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Stream<PushMessage> get foregroundMessages => _foregroundController.stream;

  @override
  Stream<PushMessage> get openedAppMessages => _openedAppController.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<Either<Exception, void>> initLocalNotifications({
    required void Function(String? payload) onTap,
  }) async => right(null);

  @override
  Future<Either<Exception, void>> showLocalNotification(
    PushMessage message,
  ) async {
    shownLocalNotifications.add(message);
    return right(null);
  }
}
