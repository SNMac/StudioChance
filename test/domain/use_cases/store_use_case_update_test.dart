import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/either_expectations.dart';

class MockStoreRepository extends Mock implements StoreRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeStore extends Fake implements Store {}

void main() {
  late StoreUseCaseImpl useCase;
  late MockStoreRepository mockStoreRepo;
  late MockUserRepository mockUserRepo;

  setUpAll(() {
    registerFallbackValue(FakeStore());
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreRepo = MockStoreRepository();
    mockUserRepo = MockUserRepository();
    useCase = StoreUseCaseImpl(
      storeRepository: mockStoreRepo,
      userRepository: mockUserRepo,
    );
  });

  group('updateStore', () {
    test('현재 유저와 함께 Repository.updateStore를 올바른 파라미터로 호출한다', () async {
      when(
        () => mockUserRepo.getCurrentUser(),
      ).thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.updateStore(
          original: any(named: 'original'),
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));

      // 폼을 연 시점의 점포(original)를 그대로 넘겨야 Repository가 동시 수정을 판정한다
      final edited = fakeStore.copyWith(address: '바뀐 주소');
      final result = await useCase.updateStore(
        original: fakeStore,
        store: edited,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expectRight(result);
      verify(
        () => mockStoreRepo.updateStore(
          original: fakeStore,
          store: edited,
          uid: fakeUser.id,
          color: StoreColor.blue,
          memo: '새 메모',
        ),
      ).called(1);
    });

    test('현재 유저 조회 실패 시 left(exception)를 반환한다', () async {
      final exception = Exception('유저 조회 실패');
      when(
        () => mockUserRepo.getCurrentUser(),
      ).thenAnswer((_) async => left(exception));

      final result = await useCase.updateStore(
        original: fakeStore,
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expectLeft(result);
      verifyNever(
        () => mockStoreRepo.updateStore(
          original: any(named: 'original'),
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('현재 유저가 null이면 left(exception)를 반환한다', () async {
      when(
        () => mockUserRepo.getCurrentUser(),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.updateStore(
        original: fakeStore,
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expectLeft(result);
    });

    test('Repository 실패 시 left(exception)를 전파한다', () async {
      final exception = Exception('점포 업데이트 실패');
      when(
        () => mockUserRepo.getCurrentUser(),
      ).thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.updateStore(
          original: any(named: 'original'),
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => left(exception));

      final result = await useCase.updateStore(
        original: fakeStore,
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expectLeft(result);
    });

    test(
      '보유한 다른 점포와 이름이 중복되면 left(StoreNameDuplicateException)를 반환하고 Repository를 호출하지 않는다',
      () async {
        final userWithTwoStores = fakeUser.copyWith(
          storeInfos: [
            ...fakeUser.storeInfos,
            UserStoreInfo(
              id: 'store-456',
              name: '다른 점포',
              role: UserRole.admin,
              color: StoreColor.blue,
              memo: '',
            ),
          ],
        );
        when(
          () => mockUserRepo.getCurrentUser(),
        ).thenAnswer((_) async => right(userWithTwoStores));

        final duplicateNameStore = fakeStore.copyWith(name: '다른 점포');

        final result = await useCase.updateStore(
          original: duplicateNameStore,
          store: duplicateNameStore,
          color: StoreColor.blue,
          memo: '메모',
        );

        expect(expectLeft(result), isA<StoreNameDuplicateException>());
        verifyNever(
          () => mockStoreRepo.updateStore(
            original: any(named: 'original'),
            store: any(named: 'store'),
            uid: any(named: 'uid'),
            color: any(named: 'color'),
            memo: any(named: 'memo'),
          ),
        );
      },
    );

    test('자기 자신의 기존 이름은 중복으로 취급하지 않는다', () async {
      when(
        () => mockUserRepo.getCurrentUser(),
      ).thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.updateStore(
          original: any(named: 'original'),
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));

      // fakeStore.id == fakeUser.storeInfos.first.id, name도 동일 — 자기 자신이므로 통과해야 함
      final result = await useCase.updateStore(
        original: fakeStore,
        store: fakeStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expectRight(result);
    });

    // 공간명 중복 검증 로직 자체(_findDuplicateNameError)는
    // store_use_case_test.dart의 createStore 테스트에서 상세히 검증한다.
    // updateStore도 같은 private 메서드를 재사용하므로, 여기서는
    // updateStore 경로에서도 그 검증이 실제로 걸리는지(wiring)만 확인한다.
    test('같은 점포 내 공간명이 중복되면 left(SpaceNameDuplicateException)를 반환한다', () async {
      when(
        () => mockUserRepo.getCurrentUser(),
      ).thenAnswer((_) async => right(fakeUser));

      final duplicateSpaceStore = fakeStore.copyWith(
        spaceOptions: [
          SpaceOption(
            id: 'space-1',
            name: '공간A',
            priceSetting: PriceSetting.empty(),
          ),
          SpaceOption(
            id: 'space-2',
            name: '공간A',
            priceSetting: PriceSetting.empty(),
          ),
        ],
      );

      final result = await useCase.updateStore(
        original: duplicateSpaceStore,
        store: duplicateSpaceStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(expectLeft(result), isA<SpaceNameDuplicateException>());
    });
  });

  group('getStoreForEdit', () {
    test('점포가 있으면 그대로 돌려준다', () async {
      when(
        () => mockStoreRepo.getStore(fakeStore.id),
      ).thenAnswer((_) async => right(fakeStore));

      final result = await useCase.getStoreForEdit(fakeStore.id);

      expect(expectRight(result), fakeStore);
    });

    test('삭제됐거나 없는 점포면 StoreNotFoundException으로 실패한다', () async {
      when(
        () => mockStoreRepo.getStore(fakeStore.id),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.getStoreForEdit(fakeStore.id);

      expect(expectLeft(result), isA<StoreNotFoundException>());
    });

    test('조회에 실패하면 그 예외를 그대로 돌려준다', () async {
      final error = StoreNetworkException(message: '네트워크');
      when(
        () => mockStoreRepo.getStore(fakeStore.id),
      ).thenAnswer((_) async => left(error));

      final result = await useCase.getStoreForEdit(fakeStore.id);

      expect(expectLeft(result), error);
    });
  });
}
