import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
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

  // =========================================================================
  // updateStoreAlias
  // =========================================================================

  group('updateStoreAlias', () {
    // store-123은 별명 없이 '테스트 점포', store-456은 '강남'이라는 별명을 붙였다
    final user = fakeUser.copyWith(
      storeInfos: [
        ...fakeUser.storeInfos,
        const UserStoreInfo(
          id: 'store-456',
          name: '강남역 2호점',
          alias: '강남',
          role: UserRole.staff,
          color: StoreColor.blue,
          memo: '',
        ),
      ],
    );

    setUp(() {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => right(user));
      when(
        () => mockRepo.updateStoreAlias(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          alias: any(named: 'alias'),
        ),
      ).thenAnswer((_) async => right(null));
    });

    Future<Either<Exception, void>> save(String storeId, String alias) =>
        useCase.updateStoreAlias(uid: user.id, storeId: storeId, alias: alias);

    void verifyNeverSaved() {
      verifyNever(
        () => mockRepo.updateStoreAlias(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          alias: any(named: 'alias'),
        ),
      );
    }

    test('앞뒤 공백을 지우고 저장한다', () async {
      expectRight(await save('store-123', '  본점  '));

      verify(
        () => mockRepo.updateStoreAlias(
          uid: user.id,
          storeId: 'store-123',
          alias: '본점',
        ),
      ).called(1);
    });

    test('비어 있으면 별명을 지운다', () async {
      expectRight(await save('store-456', '   '));

      verify(
        () => mockRepo.updateStoreAlias(
          uid: user.id,
          storeId: 'store-456',
          alias: null,
        ),
      ).called(1);
    });

    test('점포 이름과 같은 별명도 저장한다', () async {
      expectRight(await save('store-123', '테스트 점포'));
    });

    test('다른 점포의 별명과 같으면 저장하지 않는다', () async {
      final result = await save('store-123', '강남');

      expect(expectLeft(result), isA<StoreAliasDuplicateException>());
      verifyNeverSaved();
    });

    test('별명이 없는 다른 점포의 점포 이름과 같으면 저장하지 않는다', () async {
      final result = await save('store-456', '테스트 점포');

      expect(expectLeft(result), isA<StoreAliasDuplicateException>());
      verifyNeverSaved();
    });

    test('별명이 있는 다른 점포의 점포 이름은 화면에 보이지 않으므로 같아도 저장한다', () async {
      expectRight(await save('store-123', '강남역 2호점'));
    });

    test('최대 글자 수를 넘으면 저장하지 않는다', () async {
      final result = await save('store-123', '가' * (maxStoreNameCharCount + 1));

      expect(expectLeft(result), isA<StoreAliasTooLongException>());
      verifyNeverSaved();
    });

    test('글자 수는 입력 화면처럼 글자 단위로 센다 — 이모지 하나는 한 글자다', () async {
      // 가족 이모지는 UTF-16으로 11자지만 화면에서는 한 글자다
      final alias = '가' * (maxStoreNameCharCount - 1) + '👨‍👩‍👧';

      expectRight(await save('store-123', alias));
    });
  });
}
