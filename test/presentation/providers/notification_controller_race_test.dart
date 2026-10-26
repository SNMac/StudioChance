import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/fake_notification_use_case.dart';

/// `requestPermission()`의 첫 호출만 [releasePermissionGate]가 호출될 때까지
/// 블로킹해 "OS 권한 다이얼로그에서 대기 중 다른 build()가 끼어드는" 상황을
/// 재현하는 fake. 나머지 메서드는 즉시 완료해, 뒤에 시작한 build()가 앞선
/// build()보다 먼저 끝날 수 있게 한다.
class _RacingNotificationUseCase extends FakeNotificationUseCase {
  final _permissionGate = Completer<void>();

  void releasePermissionGate() {
    if (!_permissionGate.isCompleted) _permissionGate.complete();
  }

  @override
  Future<Either<Exception, bool>> requestPermission() async {
    final result = super.requestPermission();
    if (requestPermissionCallCount == 1) {
      // 첫 build()만 다이얼로그 대기 상황처럼 블로킹시킨다.
      await _permissionGate.future;
    }
    return result;
  }
}

void main() {
  test('뒤처진 build()는 새 build()가 등록한 구독·토큰 등록을 덮어쓰지 않는다', () async {
    final useCase = _RacingNotificationUseCase();
    User? testUser;

    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => testUser),
        notificationUseCaseProvider.overrideWith((ref) => useCase),
      ],
    );
    addTearDown(container.dispose);

    final userA = fakeUser.copyWith(id: 'uidA');
    final userB = fakeUser.copyWith(id: 'uidB');

    // 1. userA로 첫 build() 시작 — requestPermission()에서 블로킹된다.
    // 실제 앱처럼 MyApp이 watch하는 상황을 만든다. 리스너 없이 read만 하면
    // riverpod 3.4에서 provider가 일시정지돼 아래 invalidate 후 재빌드가 일어나지 않는다.
    testUser = userA;
    container.listen(notificationControllerProvider, (_, _) {});

    // requestPermission()이 호출될 때까지 이벤트 루프를 펌핑한다.
    await pumpEventQueue();
    expect(
      useCase.requestPermissionCallCount,
      1,
      reason: '첫 build()가 requestPermission()에서 블로킹돼야 race 조건이 재현된다',
    );

    // 2. userA의 build()가 아직 블로킹된 상태에서 userB로 즉시 전환한다.
    //    (watch 중인 uid가 바뀌므로 재빌드가 자동으로 예약된다)
    testUser = userB;
    container.invalidate(currentUserProvider);

    // userB의 build()는 requestPermission()이 즉시 완료되므로 끝까지 진행된다.
    await container.read(notificationControllerProvider.future);

    // 3. 이제야 userA의 build()를 풀어준다 — 뒤늦게 재개된다.
    useCase.releasePermissionGate();
    await pumpEventQueue();

    // userB의 초기 FCM 토큰 등록만 있어야 하고, 뒤처진 userA의 등록은 없어야 한다.
    expect(useCase.registerFcmTokenCalls, [('uidB', null)]);

    // 살아남은 구독이 userB 것인지: 토큰 갱신 이벤트가 uidB로만 기록되는지 확인한다.
    // (userA의 build()가 자신의 구독을 살려뒀다면 여기서 uidA 항목도 함께 잡힌다)
    useCase.registerFcmTokenCalls.clear();
    useCase.emitTokenRefresh('new-token');
    await Future<void>.delayed(Duration.zero);

    expect(useCase.registerFcmTokenCalls, [('uidB', 'new-token')]);
  });
}
