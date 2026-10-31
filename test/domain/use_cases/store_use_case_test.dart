import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

void main() {
  late StoreUseCaseImpl useCase;
  late MockStoreRepository mockStoreRepo;
  late MockUserRepository mockUserRepo;
  late MockServerClockRepository mockServerClockRepo;

  setUpAll(() {
    registerFallbackValue(FakeStore());
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreRepo = MockStoreRepository();
    mockUserRepo = MockUserRepository();
    mockServerClockRepo = MockServerClockRepository();
    // 기본값: 기기 시계가 서버 시각과 맞는다
    when(() => mockServerClockRepo.getServerClockOffset())
        .thenAnswer((_) async => right(Duration.zero));
    useCase = StoreUseCaseImpl(
      storeRepository: mockStoreRepo,
      userRepository: mockUserRepo,
      serverClockRepository: mockServerClockRepo,
    );
  });

  // =========================================================================
  // createStore
  // =========================================================================

  group('createStore', () {
    test('현재 유저를 Admin으로 추가하여 Repository.createStore를 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      Store? capturedStore;
      when(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((invocation) async {
        capturedStore = invocation.namedArguments[#store] as Store;
        return right(capturedStore!);
      });

      final result = await useCase.createStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 점포 메모',
      );

      expectRight(result);
      expect(capturedStore?.memberInfos.length, 1);
      expect(capturedStore?.memberInfos.first.user.id, fakeUser.id);
      expect(capturedStore?.memberInfos.first.role, UserRole.admin);
      expect(capturedStore?.waitingMemberInfos, isEmpty);
    });

    test('createStore 호출 시 color와 memo가 그대로 전달된다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(fakeStore));

      await useCase.createStore(
        store: fakeStore,
        color: StoreColor.green,
        memo: '메모 내용',
      );

      verify(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: StoreColor.green,
          memo: '메모 내용',
        ),
      ).called(1);
    });

    test('유저 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final result = await useCase.createStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expectLeft(result);
      verifyNever(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => left(Exception('점포 생성 실패')));

      final result = await useCase.createStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expectLeft(result);
    });

    test('보유한 다른 점포와 이름이 중복되면 left(StoreNameDuplicateException)를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final duplicateNameStore = fakeStore.copyWith(
        id: '',
        name: fakeUser.storeInfos.first.name,
      );

      final result = await useCase.createStore(
        store: duplicateNameStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(expectLeft(result), isA<StoreNameDuplicateException>());
      verifyNever(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('같은 점포 내 공간명이 중복되면 left(SpaceNameDuplicateException)를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final duplicateSpaceStore = fakeStore.copyWith(
        id: '',
        name: '새 점포',
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

      final result = await useCase.createStore(
        store: duplicateSpaceStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(expectLeft(result), isA<SpaceNameDuplicateException>());
      verifyNever(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    group('점포 이름 중복은 내 화면 이름(점포 별명, 없으면 점포 이름)과 비교한다', () {
      final aliasedUser = fakeUser.copyWith(
        storeInfos: [fakeUser.storeInfos.first.copyWith(alias: '강남')],
      );

      setUp(() {
        when(() => mockUserRepo.getCurrentUser())
            .thenAnswer((_) async => right(aliasedUser));
        when(
          () => mockStoreRepo.createStore(
            store: any(named: 'store'),
            color: any(named: 'color'),
            memo: any(named: 'memo'),
          ),
        ).thenAnswer((_) async => right(fakeStore));
      });

      test('다른 점포의 별명과 같으면 left(StoreNameDuplicateException)', () async {
        final result = await useCase.createStore(
          store: fakeStore.copyWith(id: '', name: '강남'),
          color: StoreColor.blue,
          memo: '',
        );

        expect(expectLeft(result), isA<StoreNameDuplicateException>());
      });

      test('별명을 붙인 다른 점포의 점포 이름과는 같아도 만든다', () async {
        final result = await useCase.createStore(
          store: fakeStore.copyWith(
            id: '',
            name: fakeUser.storeInfos.first.name,
          ),
          color: StoreColor.blue,
          memo: '',
        );

        expectRight(result);
      });
    });
  });

  // =========================================================================
  // joinStore — 점포 별명
  // =========================================================================

  group('joinStore 점포 별명', () {
    setUpAll(() => registerFallbackValue(UserRole.staff));

    setUp(() {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.requestJoinStore(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
          role: any(named: 'role'),
          color: any(named: 'color'),
          storeName: any(named: 'storeName'),
          alias: any(named: 'alias'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));
    });

    Future<Either<Exception, void>> join(String alias) => useCase.joinStore(
      storeId: 'store-new',
      storeName: '새 점포',
      alias: alias,
      role: UserRole.staff,
      color: StoreColor.red,
      memo: '',
    );

    test('점포 이름과 앞뒤 공백을 지운 별명을 넘긴다', () async {
      expectRight(await join('  새 별명  '));

      verify(
        () => mockStoreRepo.requestJoinStore(
          storeId: 'store-new',
          uid: fakeUser.id,
          role: UserRole.staff,
          color: StoreColor.red,
          storeName: '새 점포',
          alias: '새 별명',
          memo: '',
        ),
      ).called(1);
    });

    test('별명이 비어 있으면 별명 없이 신청한다', () async {
      expectRight(await join('   '));

      verify(
        () => mockStoreRepo.requestJoinStore(
          storeId: 'store-new',
          uid: fakeUser.id,
          role: UserRole.staff,
          color: StoreColor.red,
          storeName: '새 점포',
          alias: null,
          memo: '',
        ),
      ).called(1);
    });

    test('별명이 내 다른 점포의 화면 이름과 같으면 신청하지 않는다', () async {
      final result = await join(fakeUser.storeInfos.first.name);

      expect(expectLeft(result), isA<StoreAliasDuplicateException>());
      verifyNever(
        () => mockStoreRepo.requestJoinStore(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
          role: any(named: 'role'),
          color: any(named: 'color'),
          storeName: any(named: 'storeName'),
          alias: any(named: 'alias'),
          memo: any(named: 'memo'),
        ),
      );
    });
  });

  // =========================================================================
  // getStoreByInviteCode
  // =========================================================================

  group('getStoreByInviteCode', () {
    test('초대 코드를 그대로 Repository에 전달한다', () async {
      when(() => mockStoreRepo.getStoreByInviteCode(any()))
          .thenAnswer((_) async => right(null));

      await useCase.getStoreByInviteCode('VALID1');

      verify(() => mockStoreRepo.getStoreByInviteCode('VALID1')).called(1);
    });
  });

  // =========================================================================
  // softDeleteStore
  // =========================================================================

  group('softDeleteStore', () {
    test('Repository.softDeleteStore를 그대로 위임한다', () async {
      when(() => mockStoreRepo.softDeleteStore(any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase.softDeleteStore('store-123');

      expectRight(result);
      verify(() => mockStoreRepo.softDeleteStore('store-123')).called(1);
    });

    test('기기 시계가 하루 넘게 틀리면 쓰지 않고 시계를 고치라고 알린다', () async {
      when(() => mockServerClockRepo.getServerClockOffset())
          .thenAnswer((_) async => right(const Duration(days: 2)));

      final result = await useCase.softDeleteStore('store-123');

      expect(expectLeft(result), isA<StoreDeviceClockMismatchException>());
      verifyNever(() => mockStoreRepo.softDeleteStore(any()));
    });

    test('서버 시각을 구하지 못하면 확인 없이 삭제한다', () async {
      when(() => mockServerClockRepo.getServerClockOffset())
          .thenAnswer((_) async => left(Exception('오프라인')));
      when(() => mockStoreRepo.softDeleteStore(any()))
          .thenAnswer((_) async => right(null));

      expectRight(await useCase.softDeleteStore('store-123'));
      verify(() => mockStoreRepo.softDeleteStore('store-123')).called(1);
    });

    test('점포 복구는 Repository.restoreStore를 그대로 위임한다', () async {
      when(() => mockStoreRepo.restoreStore(any()))
          .thenAnswer((_) async => right(null));

      expectRight(await useCase.restoreStore('store-123'));
      verify(() => mockStoreRepo.restoreStore('store-123')).called(1);
    });

    test('영구 삭제는 Repository.permanentlyDeleteStore를 그대로 위임한다', () async {
      when(() => mockStoreRepo.permanentlyDeleteStore(any()))
          .thenAnswer((_) async => right(null));

      expectRight(await useCase.permanentlyDeleteStore('store-123'));
      verify(() => mockStoreRepo.permanentlyDeleteStore('store-123')).called(1);
    });
  });
}
