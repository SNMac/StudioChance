import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart';

import '../../../../helpers/fake_entities.dart';

class MockStoreUseCase extends Mock implements StoreUseCase {}

void main() {
  late MockStoreUseCase mockStoreUseCase;
  late ProviderContainer container;

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    container = ProviderContainer(
      overrides: [
        storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  // =========================================================================
  // onCodeChanged
  // =========================================================================

  group('onCodeChanged', () {
    test('소문자 입력 시 대문자로 변환하여 저장한다', () {
      final notifier = container.read(
        inviteCodeVerificationControllerProvider.notifier,
      );
      notifier.onCodeChanged('abc123');

      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.inviteCode, 'ABC123');
    });
  });

  // =========================================================================
  // verifyInviteCode
  // =========================================================================

  group('verifyInviteCode', () {
    group('점포가 존재할 때', () {
      setUp(() {
        when(() => mockStoreUseCase.getStoreByInviteCode(any()))
            .thenAnswer((_) async => right(fakeStore));
      });

      test('status가 AsyncData(store)가 된다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status, isA<AsyncData<Store?>>());
        expect(state.status.value, fakeStore);
      });

      test('입력된 코드로 UseCase를 호출한다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('XYZ999');
        await notifier.verifyInviteCode();

        verify(() => mockStoreUseCase.getStoreByInviteCode('XYZ999')).called(1);
      });
    });

    group('점포가 없을 때', () {
      setUp(() {
        when(() => mockStoreUseCase.getStoreByInviteCode(any()))
            .thenAnswer((_) async => right(null));
      });

      test('status가 AsyncData(null)이 된다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status, isA<AsyncData<Store?>>());
        expect(state.status.value, isNull);
      });
    });

    group('오류 발생 시', () {
      final exception = StoreNetworkException(message: '네트워크 오류');

      setUp(() {
        when(() => mockStoreUseCase.getStoreByInviteCode(any()))
            .thenAnswer((_) async => left(exception));
      });

      test('status가 AsyncError가 된다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status, isA<AsyncError<Store?>>());
      });

      test('status.error가 원본 예외 타입을 유지한다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status.error, isA<StoreNetworkException>());
      });
    });
  });

  // =========================================================================
  // isValid
  // =========================================================================

  group('isValid', () {
    test('6자 영문 대문자+숫자 조합이면 true를 반환한다', () {
      final notifier = container.read(
        inviteCodeVerificationControllerProvider.notifier,
      );
      notifier.onCodeChanged('ABC123');

      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.isValid, isTrue);
    });

    test('5자이면 false를 반환한다', () {
      final notifier = container.read(
        inviteCodeVerificationControllerProvider.notifier,
      );
      notifier.onCodeChanged('AB123');

      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.isValid, isFalse);
    });

    test('빈 값이면 false를 반환한다', () {
      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.isValid, isFalse);
    });
  });
}
