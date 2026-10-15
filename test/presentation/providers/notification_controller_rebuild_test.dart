import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';

import '../../helpers/fake_entities.dart';

/// 알림 초기화가 몇 번 실행됐는지 확인하기 위해 호출을 기록하는 fake.
class _RecordingNotificationUseCase implements NotificationUseCase {
  final _tokenController = StreamController<String>.broadcast();
  final _foregroundController = StreamController<PushMessage>.broadcast();
  final _openedAppController = StreamController<PushMessage>.broadcast();

  int requestPermissionCallCount = 0;

  /// (uid, token) — token은 초기 등록이면 null.
  final List<(String uid, String? token)> registerFcmTokenCalls = [];

  void emitTokenRefresh(String token) => _tokenController.add(token);

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
  Future<Either<Exception, void>> enableForegroundPresentation() async =>
      right(null);

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
  ) async => right(null);
}

/// 비동기 build()와 스트림 리스너가 실행될 기회를 준다.
Future<void> _pump() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _RecordingNotificationUseCase useCase;
  late ProviderContainer container;
  User? currentUser;

  setUp(() {
    useCase = _RecordingNotificationUseCase();
    container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => currentUser),
        notificationUseCaseProvider.overrideWith((ref) => useCase),
      ],
    );
    // MyApp이 watch하는 것처럼 계속 구독 중인 상태를 만든다.
    container.listen(notificationControllerProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await useCase.dispose();
  });

  /// [user]로 사용자 정보가 갱신된 상황(닉네임 변경, 점포 생성·수정 등)을 만든다.
  Future<void> refreshCurrentUser(User? user) async {
    currentUser = user;
    container.invalidate(currentUserProvider);
    await _pump();
    await container.read(notificationControllerProvider.future);
  }

  test('같은 계정의 사용자 정보가 갱신돼도 알림 초기화를 다시 하지 않는다', () async {
    currentUser = fakeUser.copyWith(id: 'uidA');
    await container.read(notificationControllerProvider.future);

    await refreshCurrentUser(fakeUser.copyWith(id: 'uidA', nickname: '새 닉네임'));

    expect(useCase.registerFcmTokenCalls, [
      ('uidA', null),
    ], reason: '같은 계정이면 FCM 토큰을 다시 쓸 이유가 없다');
    expect(useCase.requestPermissionCallCount, 1);

    // 구독을 해제했다가 다시 걸지 않았으므로 토큰 갱신이 계속 처리돼야 한다.
    useCase.registerFcmTokenCalls.clear();
    useCase.emitTokenRefresh('new-token');
    await _pump();

    expect(useCase.registerFcmTokenCalls, [('uidA', 'new-token')]);
  });

  test('로그아웃 후 다른 계정으로 로그인하면 새 계정에 FCM 토큰을 등록한다', () async {
    currentUser = fakeUser.copyWith(id: 'uidA');
    await container.read(notificationControllerProvider.future);

    await refreshCurrentUser(null);
    await refreshCurrentUser(fakeUser.copyWith(id: 'uidB'));

    expect(useCase.registerFcmTokenCalls, [('uidA', null), ('uidB', null)]);

    // 토큰 갱신은 새 계정으로만 기록돼야 한다.
    useCase.registerFcmTokenCalls.clear();
    useCase.emitTokenRefresh('new-token');
    await _pump();

    expect(useCase.registerFcmTokenCalls, [('uidB', 'new-token')]);
  });
}
