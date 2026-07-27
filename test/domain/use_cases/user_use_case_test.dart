import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';

import '../../helpers/fake_entities.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserUseCaseImpl useCase;
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
    useCase = UserUseCaseImpl(mockRepo);
  });

  // =========================================================================
  // getCurrentUser
  // =========================================================================

  group('getCurrentUser', () {
    test('유저가 있는 경우 right(user)를 반환한다', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.getCurrentUser();

      expect(result.getRight().toNullable(), fakeUser);
    });

    test('유저가 null인 경우 right(null)를 반환한다', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.getCurrentUser();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), isNull);
    });

    test('Repository 실패를 그대로 전파한다', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 조회 실패')));

      final result = await useCase.getCurrentUser();

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // updateUser
  // =========================================================================

  group('updateUser', () {
    test('uid와 nickname을 올바른 파라미터로 Repository에 전달한다', () async {
      when(
        () => mockRepo.updateUser(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.updateUser(
        uid: fakeUser.id,
        nickname: '새닉네임',
      );

      expect(result.isRight(), true);
      verify(
        () => mockRepo.updateUser(
          uid: fakeUser.id,
          email: null,
          nickname: '새닉네임',
        ),
      ).called(1);
    });

    test('Repository 실패를 그대로 전파한다', () async {
      when(
        () => mockRepo.updateUser(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => left(Exception('업데이트 실패')));

      final result = await useCase.updateUser(
        uid: fakeUser.id,
        nickname: '새닉네임',
      );

      expect(result.isLeft(), true);
    });
  });
}
