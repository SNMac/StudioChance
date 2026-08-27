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

  void stubIssue(Either<Exception, InviteInfo> result) {
    when(
      () => mockStoreUseCase.createInviteCode(
        any(),
        forceRegenerate: any(named: 'forceRegenerate'),
      ),
    ).thenAnswer((_) async => result);
  }

  // =========================================================================
  // issue
  // =========================================================================

  group('issue', () {
    group('발급에 성공했을 때', () {
      setUp(() => stubIssue(right(inviteInfo)));

      test('상태가 AsyncData가 된다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        expect(container.read(inviteCodeControllerProvider), isA<AsyncData>());
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

      setUp(() => stubIssue(left(exception)));

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
  // 점포 캐시 무효화
  //
  // 발급된 코드는 컨트롤러가 아니라 점포 문서를 통해 화면에 도달한다.
  // 이 무효화가 빠지면 새 코드가 영영 표시되지 않는다.
  // =========================================================================

  group('점포 캐시 무효화', () {
    /// storeId별 조회 횟수를 세는 컨테이너.
    ({ProviderContainer container, Map<String, int> fetchCounts}) countingSetup(
      List<String> storeIds,
    ) {
      final fetchCounts = {for (final id in storeIds) id: 0};
      final c = ProviderContainer(
        overrides: [
          storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
          for (final id in storeIds)
            storeDetailProvider(id).overrideWith((ref) async {
              fetchCounts[id] = fetchCounts[id]! + 1;
              return null;
            }),
        ],
      );
      addTearDown(c.dispose);

      // 구독이 없으면 무효화해도 재조회가 일어나지 않는다.
      for (final id in storeIds) {
        c.listen(storeDetailProvider(id), (_, _) {});
      }
      return (container: c, fetchCounts: fetchCounts);
    }

    test('발급에 성공하면 해당 점포를 다시 조회한다', () async {
      stubIssue(right(inviteInfo));
      final (container: c, fetchCounts: counts) = countingSetup(['store1']);
      await c.read(storeDetailProvider('store1').future);
      expect(counts['store1'], 1);

      await c.read(inviteCodeControllerProvider.notifier).issue('store1');
      await c.read(storeDetailProvider('store1').future);

      expect(counts['store1'], 2);
    });

    test('발급에 실패하면 다시 조회하지 않는다', () async {
      stubIssue(left(StoreNetworkException(message: '네트워크 오류')));
      final (container: c, fetchCounts: counts) = countingSetup(['store1']);
      await c.read(storeDetailProvider('store1').future);

      await c.read(inviteCodeControllerProvider.notifier).issue('store1');
      await Future<void>.delayed(Duration.zero);

      expect(counts['store1'], 1);
    });

    test('다른 점포의 캐시는 건드리지 않는다', () async {
      stubIssue(right(inviteInfo));
      final (container: c, fetchCounts: counts) = countingSetup([
        'store1',
        'store2',
      ]);
      await c.read(storeDetailProvider('store2').future);
      expect(counts['store2'], 1);

      await c.read(inviteCodeControllerProvider.notifier).issue('store1');
      await Future<void>.delayed(Duration.zero);

      expect(counts['store2'], 1);
    });
  });
}
