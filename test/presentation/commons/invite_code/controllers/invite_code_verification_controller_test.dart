import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/invite_store_preview.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart';
import 'package:studio_chance/presentation/commons/role_selection/controllers/role_selection_controller.dart';

class MockStoreUseCase extends Mock implements StoreUseCase {}

const testPreview = InviteStorePreview(
  storeId: 'store-1',
  storeName: '테스트 점포',
  address: '경기 오산시 경기대로285번길 26',
  addressDetail: '3층',
  adminName: '홍길동',
);

void main() {
  late MockStoreUseCase mockStoreUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(UserRole.none);
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    container = ProviderContainer(
      overrides: [storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase)],
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
        when(
          () => mockStoreUseCase.getStoreByInviteCode(any()),
        ).thenAnswer((_) async => right(testPreview));
      });

      test('status가 AsyncData(store)가 된다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status, isA<AsyncData<InviteStorePreview?>>());
        expect(state.status.value, testPreview);
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
        when(
          () => mockStoreUseCase.getStoreByInviteCode(any()),
        ).thenAnswer((_) async => right(null));
      });

      test('status가 AsyncData(null)이 된다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status, isA<AsyncData<InviteStorePreview?>>());
        expect(state.status.value, isNull);
      });
    });

    group('오류 발생 시', () {
      final exception = StoreNetworkException(message: '네트워크 오류');

      setUp(() {
        when(
          () => mockStoreUseCase.getStoreByInviteCode(any()),
        ).thenAnswer((_) async => left(exception));
      });

      test('status가 AsyncError가 된다', () async {
        final notifier = container.read(
          inviteCodeVerificationControllerProvider.notifier,
        );
        notifier.onCodeChanged('ABC123');
        await notifier.verifyInviteCode();

        final state = container.read(inviteCodeVerificationControllerProvider);
        expect(state.status, isA<AsyncError<InviteStorePreview?>>());
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

  // =========================================================================
  // submitJoinRequest
  // =========================================================================

  group('submitJoinRequest', () {
    /// 초대 코드 조회에 성공해 점포 확인 화면에 도달한 상태를 만든다
    Future<InviteCodeVerificationController> arrangeVerified() async {
      when(
        () => mockStoreUseCase.getStoreByInviteCode(any()),
      ).thenAnswer((_) async => right(testPreview));

      final notifier = container.read(
        inviteCodeVerificationControllerProvider.notifier,
      );
      notifier.onCodeChanged('ABC123');
      await notifier.verifyInviteCode();
      return notifier;
    }

    void arrangeJoinResult(Either<Exception, void> result) {
      when(
        () => mockStoreUseCase.joinStore(
          storeId: any(named: 'storeId'),
          storeAlias: any(named: 'storeAlias'),
          role: any(named: 'role'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('초대 코드 조회 성공 시 점포 별명 기본값이 점포명으로 채워진다', () async {
      await arrangeVerified();

      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.storeAlias, testPreview.storeName);
      expect(state.canSubmit, isTrue);
    });

    test('선택한 역할·색상·별명·메모로 UseCase를 호출한다', () async {
      final notifier = await arrangeVerified();
      arrangeJoinResult(right(null));

      container
          .read(roleSelectionControllerProvider.notifier)
          .setRole(UserRole.staff);
      notifier.setStoreAlias('  내 점포  ');
      notifier.setColor(StoreColor.blue);
      notifier.setMemo('메모입니다');

      await notifier.submitJoinRequest();

      verify(
        () => mockStoreUseCase.joinStore(
          storeId: testPreview.storeId,
          storeAlias: '내 점포',
          role: UserRole.staff,
          color: StoreColor.blue,
          memo: '메모입니다',
        ),
      ).called(1);
    });

    test('성공 시 submitStatus가 AsyncData가 된다', () async {
      final notifier = await arrangeVerified();
      arrangeJoinResult(right(null));

      await notifier.submitJoinRequest();

      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.submitStatus, isA<AsyncData<void>>());
    });

    test('실패 시 submitStatus가 원본 예외를 담은 AsyncError가 된다', () async {
      final notifier = await arrangeVerified();
      arrangeJoinResult(left(StoreNetworkException(message: '네트워크 오류')));

      await notifier.submitJoinRequest();

      final state = container.read(inviteCodeVerificationControllerProvider);
      expect(state.submitStatus, isA<AsyncError<void>>());
      expect(state.submitStatus.error, isA<StoreNetworkException>());
    });

    test('점포 별명이 비어 있으면 제출하지 않는다', () async {
      final notifier = await arrangeVerified();
      arrangeJoinResult(right(null));

      notifier.setStoreAlias('   ');
      await notifier.submitJoinRequest();

      verifyNever(
        () => mockStoreUseCase.joinStore(
          storeId: any(named: 'storeId'),
          storeAlias: any(named: 'storeAlias'),
          role: any(named: 'role'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('제출 중에는 중복 호출해도 UseCase가 한 번만 호출된다', () async {
      final notifier = await arrangeVerified();
      arrangeJoinResult(right(null));

      final first = notifier.submitJoinRequest();
      final second = notifier.submitJoinRequest();
      await Future.wait([first, second]);

      verify(
        () => mockStoreUseCase.joinStore(
          storeId: any(named: 'storeId'),
          storeAlias: any(named: 'storeAlias'),
          role: any(named: 'role'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).called(1);
    });
  });
}
