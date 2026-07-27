import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_nickname_controller.dart';

import '../../../helpers/fake_entities.dart';

class MockUserUseCase extends Mock implements UserUseCase {}

void main() {
  late MockUserUseCase mockUserUseCase;
  late ProviderContainer container;

  setUp(() {
    mockUserUseCase = MockUserUseCase();
    container = ProviderContainer(
      overrides: [
        userUseCaseProvider.overrideWith((ref) => mockUserUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('saveNicknameToRemote', () {
    test('닉네임이 비어있으면 UserValidationException으로 AsyncError가 된다', () async {
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('   ');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, isA<UserValidationException>());
      verifyNever(() => mockUserUseCase.getCurrentUser());
    });

    test('getCurrentUser 실패 시 원본 예외로 AsyncError가 된다', () async {
      final exception = UserNotFoundException(message: '조회 실패');
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => left(exception));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, exception);
      verifyNever(
        () => mockUserUseCase.updateUser(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
        ),
      );
    });

    test('currentUser가 null이면 UserNotFoundException으로 AsyncError가 된다', () async {
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => right(null));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, isA<UserNotFoundException>());
    });

    test('updateUser 실패 시 원본 예외로 AsyncError가 된다', () async {
      final exception = UserNotFoundException(message: '업데이트 실패');
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockUserUseCase.updateUser(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => left(exception));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, exception);
    });

    test('성공 시 AsyncData(null)이 되고 updateUser가 올바른 인자로 호출된다', () async {
      when(() => mockUserUseCase.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockUserUseCase.updateUser(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => right(null));
      final notifier = container.read(
        onboardingNicknameControllerProvider.notifier,
      );

      await notifier.saveNicknameToRemote('새닉네임');

      final state = container.read(onboardingNicknameControllerProvider);
      expect(state, const AsyncData<void>(null));
      verify(
        () => mockUserUseCase.updateUser(
          uid: fakeUser.id,
          nickname: '새닉네임',
        ),
      ).called(1);
    });
  });
}
