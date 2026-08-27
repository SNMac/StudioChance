import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/invite_code_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

class MockStoreUseCase extends Mock implements StoreUseCase {}

void main() {
  const inviteInfo = InviteInfo(inviteCode: 'A7K2P9');

  late MockStoreUseCase mockStoreUseCase;
  late ProviderContainer container;

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    container = ProviderContainer(
      overrides: [storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase)],
    );
  });

  tearDown(() => container.dispose());

  // =========================================================================
  // build
  // =========================================================================

  group('build', () {
    test('초기 상태는 AsyncData(null)이다', () {
      final state = container.read(inviteCodeControllerProvider);

      expect(state, isA<AsyncData<InviteInfo?>>());
      expect(state.value, isNull);
    });
  });

  // =========================================================================
  // issue
  // =========================================================================

  group('issue', () {
    group('발급에 성공했을 때', () {
      setUp(() {
        when(
          () => mockStoreUseCase.createInviteCode(
            any(),
            forceRegenerate: any(named: 'forceRegenerate'),
          ),
        ).thenAnswer((_) async => right(inviteInfo));
      });

      test('상태가 AsyncData(발급된 코드)가 된다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        final state = container.read(inviteCodeControllerProvider);
        expect(state, isA<AsyncData<InviteInfo?>>());
        expect(state.value, inviteInfo);
      });

      test('전달된 storeId로 UseCase를 호출한다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store42');

        verify(
          () => mockStoreUseCase.createInviteCode(
            'store42',
            forceRegenerate: false,
          ),
        ).called(1);
      });

      test('기본값에서는 강제 재발급을 요청하지 않는다 — 유효 코드 재사용은 Repository가 판단한다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        verifyNever(
          () => mockStoreUseCase.createInviteCode(any(), forceRegenerate: true),
        );
      });

      test('forceRegenerate를 넘기면 그대로 UseCase에 전달한다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1', forceRegenerate: true);

        verify(
          () => mockStoreUseCase.createInviteCode(
            'store1',
            forceRegenerate: true,
          ),
        ).called(1);
      });

      test('발급 중에는 상태가 AsyncLoading이다 — UI가 중복 발급을 차단할 수 있어야 한다', () async {
        final future = container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        expect(container.read(inviteCodeControllerProvider).isLoading, isTrue);
        await future;
      });
    });

    group('발급에 실패했을 때', () {
      final exception = StoreNetworkException(message: '네트워크 오류');

      setUp(() {
        when(
          () => mockStoreUseCase.createInviteCode(
            any(),
            forceRegenerate: any(named: 'forceRegenerate'),
          ),
        ).thenAnswer((_) async => left(exception));
      });

      test('상태가 AsyncError가 된다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        expect(container.read(inviteCodeControllerProvider), isA<AsyncError>());
      });

      test(
        '원본 예외 타입을 유지한다 — MyPageScreen이 AppException 여부로 다이얼로그를 가른다',
        () async {
          await container
              .read(inviteCodeControllerProvider.notifier)
              .issue('store1');

          expect(
            container.read(inviteCodeControllerProvider).error,
            isA<StoreNetworkException>(),
          );
        },
      );
    });
  });

  // =========================================================================
  // 진행 중 요청 / 캐시 무효화
  // =========================================================================

  group('발급 결과 반영', () {
    test('성공하면 해당 점포의 storeDetailProvider를 무효화한다', () async {
      // 무효화하지 않으면 모달을 다시 열 때 캐시에 남은 옛 코드가 보인다.
      var fetchCount = 0;
      final container = ProviderContainer(
        overrides: [
          storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
          storeDetailProvider('store1').overrideWith((ref) async {
            fetchCount++;
            return null;
          }),
        ],
      );
      addTearDown(container.dispose);

      when(
        () => mockStoreUseCase.createInviteCode(
          any(),
          forceRegenerate: any(named: 'forceRegenerate'),
        ),
      ).thenAnswer((_) async => right(inviteInfo));

      // 구독을 만들어 두어야 무효화 후 재조회가 실제로 일어난다.
      container.listen(storeDetailProvider('store1'), (_, _) {});
      await container.read(storeDetailProvider('store1').future);
      expect(fetchCount, 1);

      await container
          .read(inviteCodeControllerProvider.notifier)
          .issue('store1');
      await container.read(storeDetailProvider('store1').future);

      expect(fetchCount, 2);
    });

    test('요청 중 상태가 리셋되면 뒤늦게 도착한 결과를 버린다', () async {
      // 모달을 닫고 다른 점포 모달을 열면 그쪽에서 컨트롤러를 invalidate한다.
      // invalidate는 Notifier 인스턴스를 재사용하므로, 막지 않으면 앞선 점포의
      // 코드가 다른 점포 모달에 그대로 표시·공유된다.
      final completer = Completer<Either<Exception, InviteInfo>>();
      when(
        () => mockStoreUseCase.createInviteCode(
          any(),
          forceRegenerate: any(named: 'forceRegenerate'),
        ),
      ).thenAnswer((_) => completer.future);

      final future = container
          .read(inviteCodeControllerProvider.notifier)
          .issue('store1');
      expect(container.read(inviteCodeControllerProvider).isLoading, isTrue);

      container.invalidate(inviteCodeControllerProvider);
      // 리셋된 상태를 구독해 두어야 이후 상태 변화를 관찰할 수 있다.
      expect(container.read(inviteCodeControllerProvider).value, isNull);

      completer.complete(right(inviteInfo));
      await future;

      expect(container.read(inviteCodeControllerProvider).value, isNull);
    });
  });
}
