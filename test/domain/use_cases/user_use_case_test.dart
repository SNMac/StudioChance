import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
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
  // updateStoreInfo — 점포 별명
  // =========================================================================

  group('updateStoreInfo 점포 별명', () {
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
        () => mockRepo.updateStoreInfo(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          alias: any(named: 'alias'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));
    });

    void verifyNeverSaved() {
      verifyNever(
        () => mockRepo.updateStoreInfo(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          alias: any(named: 'alias'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    }

    test('앞뒤 공백을 지우고 저장한다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-123',
        alias: '  본점  ',
      );

      expectRight(result);
      verify(
        () => mockRepo.updateStoreInfo(
          uid: user.id,
          storeId: 'store-123',
          alias: '본점',
        ),
      ).called(1);
    });

    test('비어 있으면 중복을 검사하지 않고 빈 값으로 넘겨 별명을 지운다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-456',
        alias: '   ',
      );

      expectRight(result);
      verifyNever(() => mockRepo.getCurrentUser());
      verify(
        () => mockRepo.updateStoreInfo(
          uid: user.id,
          storeId: 'store-456',
          alias: '',
        ),
      ).called(1);
    });

    test('점포 이름과 같은 별명도 저장한다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-123',
        alias: '테스트 점포',
      );

      expectRight(result);
    });

    test('다른 점포의 별명과 같으면 저장하지 않는다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-123',
        alias: '강남',
      );

      expect(expectLeft(result), isA<StoreAliasDuplicateException>());
      verifyNeverSaved();
    });

    test('별명이 없는 다른 점포의 점포 이름과 같으면 저장하지 않는다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-456',
        alias: '테스트 점포',
      );

      expect(expectLeft(result), isA<StoreAliasDuplicateException>());
      verifyNeverSaved();
    });

    test('별명이 있는 다른 점포의 점포 이름은 화면에 보이지 않으므로 같아도 저장한다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-123',
        alias: '강남역 2호점',
      );

      expectRight(result);
    });

    test('색상만 바꿀 때는 중복을 검사하지 않는다', () async {
      final result = await useCase.updateStoreInfo(
        uid: user.id,
        storeId: 'store-123',
        color: StoreColor.green,
      );

      expectRight(result);
      verifyNever(() => mockRepo.getCurrentUser());
    });
  });
}
