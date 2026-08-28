import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

import '../../helpers/fake_entities.dart';

/// 포그라운드 알림 표시 경로가 플랫폼별로 갈리는 것만 검증하는 fake.
///
/// 실제 기기에서는 한 번에 한쪽 경로만 실행되므로, 반대편이 깨져도
/// 드러나지 않는다. `debugDefaultTargetPlatformOverride`로 양쪽을 고정한다.
class _RecordingNotificationUseCase implements NotificationUseCase {
  final _tokenController = StreamController<String>.broadcast();
  final _foregroundController = StreamController<PushMessage>.broadcast();
  final _openedAppController = StreamController<PushMessage>.broadcast();

  int enableForegroundPresentationCallCount = 0;
  final List<PushMessage> shownLocalNotifications = [];

  void emitForegroundMessage(PushMessage message) =>
      _foregroundController.add(message);

  Future<void> dispose() async {
    await _tokenController.close();
    await _foregroundController.close();
    await _openedAppController.close();
  }

  @override
  Future<Either<Exception, bool>> requestPermission() async => right(true);

  @override
  Future<Either<Exception, void>> enableForegroundPresentation() async {
    enableForegroundPresentationCallCount++;
    return right(null);
  }

  @override
  Future<Either<Exception, void>> registerFcmToken({
    required String uid,
    String? token,
  }) async => right(null);

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

const _message = PushMessage(
  type: 'joinRequest',
  data: {'type': 'joinRequest', 'storeId': 'store-1'},
);

Future<_RecordingNotificationUseCase> _runBuild(TargetPlatform platform) async {
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);

  final useCase = _RecordingNotificationUseCase();
  addTearDown(useCase.dispose);

  final container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWith((ref) => fakeUser),
      notificationUseCaseProvider.overrideWith((ref) => useCase),
    ],
  );
  addTearDown(container.dispose);

  await container.read(notificationControllerProvider.future);

  useCase.emitForegroundMessage(_message);
  // 브로드캐스트 스트림 리스너가 실행될 기회를 준다.
  await Future<void>.delayed(Duration.zero);

  return useCase;
}

void main() {
  test('iOS는 시스템 표시를 켜고 로컬 알림을 띄우지 않는다', () async {
    final useCase = await _runBuild(TargetPlatform.iOS);

    expect(
      useCase.enableForegroundPresentationCallCount,
      1,
      reason:
          '이 설정을 끄면 delegate가 presentationOptions=0을 반환해 '
          '수신 푸시와 로컬 알림이 모두 억제된다',
    );
    expect(
      useCase.shownLocalNotifications,
      isEmpty,
      reason: '시스템이 배너를 표시하므로 로컬 알림까지 띄우면 두 번 보인다',
    );
  });

  test('Android는 로컬 알림으로 표시하고 시스템 표시 설정을 건드리지 않는다', () async {
    final useCase = await _runBuild(TargetPlatform.android);

    expect(
      useCase.shownLocalNotifications,
      [_message],
      reason: 'Android는 FCM이 포그라운드 알림을 표시하지 않아 로컬 알림이 필요하다',
    );
    expect(
      useCase.enableForegroundPresentationCallCount,
      0,
      reason: 'iOS 전용 설정이다',
    );
  });

  test('가입 신청 알림을 받으면 해당 점포 조회를 다시 한다', () async {
    // storeDetailProvider는 일회성 조회라, 무효화하지 않으면 마이페이지가
    // 살아 있는 동안 다른 기기에서 들어온 신청이 배지·모달에 보이지 않는다.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    var fetchCount = 0;
    final useCase = _RecordingNotificationUseCase();
    addTearDown(useCase.dispose);

    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => fakeUser),
        notificationUseCaseProvider.overrideWith((ref) => useCase),
        storeDetailProvider('store-1').overrideWith((ref) async {
          fetchCount++;
          return fakeStore;
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationControllerProvider.future);

    // 마이페이지의 대기 인원 배지처럼 계속 구독 중인 상태를 만든다.
    container.listen(storeDetailProvider('store-1'), (_, _) {});
    await container.read(storeDetailProvider('store-1').future);
    expect(fetchCount, 1);

    useCase.emitForegroundMessage(_message);
    await Future<void>.delayed(Duration.zero);

    await container.read(storeDetailProvider('store-1').future);
    expect(fetchCount, 2, reason: '알림 수신 시 점포 조회가 무효화되어야 한다');
  });
}
