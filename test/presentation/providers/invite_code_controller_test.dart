import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/invite_code_controller.dart';

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
          () => mockStoreUseCase.createInviteCode(any()),
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

        verify(() => mockStoreUseCase.createInviteCode('store42')).called(1);
      });

      test('강제 재발급을 요청하지 않는다 — 유효 코드 재사용은 Repository가 판단한다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        verifyNever(
          () => mockStoreUseCase.createInviteCode(any(), forceRegenerate: true),
        );
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
          () => mockStoreUseCase.createInviteCode(any()),
        ).thenAnswer((_) async => left(exception));
      });

      test('상태가 AsyncError가 된다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        expect(container.read(inviteCodeControllerProvider), isA<AsyncError>());
      });

      test('원본 예외 타입을 유지한다 — MyPageScreen이 AppException 여부로 다이얼로그를 가른다', () async {
        await container
            .read(inviteCodeControllerProvider.notifier)
            .issue('store1');

        expect(
          container.read(inviteCodeControllerProvider).error,
          isA<StoreNetworkException>(),
        );
      });
    });
  });
}
