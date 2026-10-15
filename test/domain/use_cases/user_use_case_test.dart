import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

void main() {
  late UserUseCaseImpl useCase;
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
    useCase = UserUseCaseImpl(mockRepo);
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

      expectRight(result);
      verify(
        () => mockRepo.updateUser(
          uid: fakeUser.id,
          email: null,
          nickname: '새닉네임',
        ),
      ).called(1);
    });
  });
}
