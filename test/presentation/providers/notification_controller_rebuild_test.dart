import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/fake_notification_use_case.dart';

void main() {
  late FakeNotificationUseCase useCase;
  late ProviderContainer container;
  User? currentUser;

  setUp(() {
    currentUser = null;
    useCase = FakeNotificationUseCase();
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
    await pumpEventQueue();
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
    await pumpEventQueue();

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
    await pumpEventQueue();

    expect(useCase.registerFcmTokenCalls, [('uidB', 'new-token')]);
  });
}
