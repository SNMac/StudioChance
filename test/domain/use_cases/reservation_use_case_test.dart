import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/enums/weekday.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';

import '../../helpers/fake_entities.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockStoreRepository extends Mock implements StoreRepository {}

class FakeReservation extends Fake implements Reservation {}

/// 평일(월~금) 시간당 요금 + 인원 추가 요금이 설정된 PriceSetting
///
/// - 기본 요금: 0~24시 시간당 [hourlyPrice]원
/// - 인원 추가: 기준 2명 초과 시 1인·1시간당 1,000원
PriceSetting _weekdayHourlySetting(int hourlyPrice) {
  return PriceSetting(
    dayGroups: [
      DayGroup(
        days: [
          Weekday.monday,
          Weekday.tuesday,
          Weekday.wednesday,
          Weekday.thursday,
          Weekday.friday,
        ],
        headcountRule: const HeadcountRule(
          headcountBase: 2,
          headcountExtraPrice: 1000,
          isHeadcountHourly: true,
          isHeadcountPerPerson: true,
        ),
        timeSlots: [
          TimeSlot(
            isAllDay: false,
            startTime: 0,
            endTime: 1440,
            price: hourlyPrice,
            isHourly: true,
            isPerPerson: false,
          ),
        ],
      ),
    ],
  );
}

/// 공간 A(시간당 10,000원), 공간 B(시간당 20,000원)를 가진 점포
final _pricedStore = fakeStore.copyWith(
  spaceOptions: [
    SpaceOption(
      id: 'space-a',
      name: '공간 A',
      priceSetting: _weekdayHourlySetting(10000),
    ),
    SpaceOption(
      id: 'space-b',
      name: '공간 B',
      priceSetting: _weekdayHourlySetting(20000),
    ),
  ],
);

void main() {
  late ReservationUseCaseImpl useCase;
  late MockReservationRepository mockReservationRepo;
  late MockUserRepository mockUserRepo;
  late MockStoreRepository mockStoreRepo;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeReservation());
    registerFallbackValue(ReservationStatus.pending);
  });

  setUp(() {
    mockReservationRepo = MockReservationRepository();
    mockUserRepo = MockUserRepository();
    mockStoreRepo = MockStoreRepository();
    // 기본값: store 없음 → 가격 계산 스킵, 기존 값 유지
    when(
      () => mockStoreRepo.getStore(any()),
    ).thenAnswer((_) async => right(null));
    useCase = ReservationUseCaseImpl(
      reservationRepository: mockReservationRepo,
      userRepository: mockUserRepo,
      storeRepository: mockStoreRepo,
    );
  });

  // =========================================================================
  // createReservation
  // =========================================================================

  group('createReservation', () {
    test('writer.user만 현재 로그인 유저로 교체하고 writer.role은 유지하여 Repository를 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      Reservation? capturedReservation;
      when(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((invocation) async {
        capturedReservation =
            invocation.namedArguments[#reservation] as Reservation;
        return right(capturedReservation!);
      });

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      result.fold((error) => fail(error.toString()), (_) {});
      expect(capturedReservation?.writer.user.id, fakeUser.id);
      expect(capturedReservation?.writer.role, UserRole.admin);
    });

    test('유저 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
      verifyNever(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      );
    });

    test('현재 유저가 null이면 left를 반환한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((_) async => left(Exception('생성 실패')));

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
    });

    test('Store 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => left(Exception('Store 조회 실패')));

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
      verifyNever(() => mockUserRepo.getCurrentUser());
      verifyNever(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      );
    });
  });

  // =========================================================================
  // getReservationsByDateRange
  // =========================================================================

  group('getReservationsByDateRange', () {
    final start = DateTime(2026, 5, 1);
    final end = DateTime(2026, 5, 31);

    test('currentUid를 자동으로 획득하여 Repository를 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.getReservationsByDateRange(
          storeId: any(named: 'storeId'),
          currentUid: any(named: 'currentUid'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => right([fakeReservation]));

      final result = await useCase.getReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      result.fold((error) => fail(error.toString()), (_) {});
      verify(
        () => mockReservationRepo.getReservationsByDateRange(
          storeId: 'store-123',
          currentUid: fakeUser.id,
          start: start,
          end: end,
        ),
      ).called(1);
    });

    test('유저 조회 실패 시 left를 반환한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final result = await useCase.getReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.getReservationsByDateRange(
          storeId: any(named: 'storeId'),
          currentUid: any(named: 'currentUid'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => left(Exception('조회 실패')));

      final result = await useCase.getReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
    });
  });

  // =========================================================================
  // updateReservation
  // =========================================================================

  group('updateReservation', () {
    setUp(() {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      // 기본값: 저장된 예약 없음 → 요금표 스냅샷이 없어 현재 요금 경로
      when(
        () => mockReservationRepo.getReservation(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
          currentUid: any(named: 'currentUid'),
        ),
      ).thenAnswer((_) async => right(null));
    });

    test('Repository.updateReservation을 그대로 위임한다', () async {
      when(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.updateReservation(
        reservation: fakeReservation,
      );

      result.fold((error) => fail(error.toString()), (_) {});
      verify(
        () => mockReservationRepo.updateReservation(
          reservation: fakeReservation,
        ),
      ).called(1);
    });

    test('Store 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => left(Exception('Store 조회 실패')));

      final result = await useCase.updateReservation(
        reservation: fakeReservation,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
      verifyNever(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      );
    });

    test('저장된 예약 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(
        () => mockReservationRepo.getReservation(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
          currentUid: any(named: 'currentUid'),
        ),
      ).thenAnswer((_) async => left(Exception('예약 조회 실패')));

      final result = await useCase.updateReservation(
        reservation: fakeReservation,
      );

      result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));
      verifyNever(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      );
    });
  });

  // =========================================================================
  // 가격 계산 (요금표 스냅샷)
  // =========================================================================

  // fakeReservation: 2026-05-01(금) 10:00~12:00, 4명, priceAdjustment -5,000원
  group('가격 계산', () {
    Reservation? capturedCreate;
    Reservation? capturedUpdate;

    setUp(() {
      capturedCreate = null;
      capturedUpdate = null;
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((invocation) async {
        capturedCreate = invocation.namedArguments[#reservation] as Reservation;
        return right(capturedCreate!);
      });
      when(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((invocation) async {
        capturedUpdate = invocation.namedArguments[#reservation] as Reservation;
        return right(null);
      });
      // 기본값: 저장된 예약 없음 → 수정 시에도 현재 요금 적용
      when(
        () => mockReservationRepo.getReservation(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
          currentUid: any(named: 'currentUid'),
        ),
      ).thenAnswer((_) async => right(null));
    });

    void stubStoredReservation(Reservation stored) {
      when(
        () => mockReservationRepo.getReservation(
          storeId: stored.storeSummary.id,
          reservationId: stored.id,
          currentUid: fakeUser.id,
        ),
      ).thenAnswer((_) async => right(stored));
    }

    test('createReservation: 점포 요금 설정으로 calculatedPrice/totalPrice를 계산해 저장한다',
        () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => right(_pricedStore));

      final result = await useCase.createReservation(
        reservation: fakeReservation.copyWith(spaceOptionId: 'space-a'),
      );

      result.fold((error) => fail(error.toString()), (_) {});
      verify(() => mockStoreRepo.getStore(fakeStoreSummary.id)).called(1);
      // 기본 10,000 × 2시간 + 추가 인원 2명 × 1,000 × 2시간 = 24,000
      expect(capturedCreate?.calculatedPrice, 24000);
      // 24,000 + (-5,000)
      expect(capturedCreate?.totalPrice, 19000);
      // 이후 수정 시 재계산 기준이 되도록 사용한 요금표를 함께 저장한다
      expect(capturedCreate?.priceSetting, _weekdayHourlySetting(10000));
    });

    test('createReservation: spaceOptionId에 해당하는 공간의 요금 설정을 사용한다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => right(_pricedStore));

      await useCase.createReservation(
        reservation: fakeReservation.copyWith(spaceOptionId: 'space-b'),
      );

      // 기본 20,000 × 2시간 + 추가 인원 2명 × 1,000 × 2시간 = 44,000
      expect(capturedCreate?.calculatedPrice, 44000);
      expect(capturedCreate?.totalPrice, 39000);
    });

    test('createReservation: 점포에 공간(요금 설정)이 없으면 기존 가격을 유지한다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => right(fakeStore.copyWith(spaceOptions: [])));

      await useCase.createReservation(reservation: fakeReservation);

      expect(capturedCreate?.calculatedPrice, 50000);
      expect(capturedCreate?.totalPrice, 45000);
    });

    test('updateReservation: 저장된 요금표가 없으면 현재 요금으로 계산하고 요금표를 저장한다',
        () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => right(_pricedStore));

      final result = await useCase.updateReservation(
        reservation: fakeReservation.copyWith(spaceOptionId: 'space-a'),
      );

      result.fold((error) => fail(error.toString()), (_) {});
      verify(() => mockStoreRepo.getStore(fakeStoreSummary.id)).called(1);
      expect(capturedUpdate?.calculatedPrice, 24000);
      expect(capturedUpdate?.totalPrice, 19000);
      expect(capturedUpdate?.priceSetting, _weekdayHourlySetting(10000));
    });

    test('updateReservation: 점포에 공간(요금 설정)이 없으면 기존 가격을 유지한다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => right(fakeStore.copyWith(spaceOptions: [])));

      await useCase.updateReservation(reservation: fakeReservation);

      expect(capturedUpdate?.calculatedPrice, 50000);
      expect(capturedUpdate?.totalPrice, 45000);
    });

    group('저장된 요금표가 있을 때', () {
      // 예약 당시 공간 A 요금은 시간당 30,000원이었고, 지금은 10,000원으로 내려간 상황
      final stored = fakeReservation.copyWith(
        spaceOptionId: 'space-a',
        priceSetting: _weekdayHourlySetting(30000),
      );

      setUp(() {
        stubStoredReservation(stored);
        when(
          () => mockStoreRepo.getStore(any()),
        ).thenAnswer((_) async => right(_pricedStore));
      });

      test('updateReservation: 점포 요금이 바뀌어도 저장된 요금표로 재계산한다', () async {
        final result = await useCase.updateReservation(
          // 화면이 보낸 요금표는 신뢰하지 않고 저장된 요금표를 쓴다
          reservation: stored.copyWith(
            headCount: 3,
            priceSetting: _weekdayHourlySetting(1),
          ),
        );

        result.fold((error) => fail(error.toString()), (_) {});
        // 30,000 × 2시간 + 추가 인원 1명 × 1,000 × 2시간 = 62,000
        expect(capturedUpdate?.calculatedPrice, 62000);
        expect(capturedUpdate?.totalPrice, 57000);
        expect(capturedUpdate?.priceSetting, _weekdayHourlySetting(30000));
        verifyNever(() => mockStoreRepo.getStore(any()));
      });

      test('updateReservation: applyCurrentPrice면 현재 요금표로 재계산하고 요금표를 교체한다',
          () async {
        await useCase.updateReservation(
          reservation: stored,
          applyCurrentPrice: true,
        );

        expect(capturedUpdate?.calculatedPrice, 24000);
        expect(capturedUpdate?.totalPrice, 19000);
        expect(capturedUpdate?.priceSetting, _weekdayHourlySetting(10000));
      });

      test('updateReservation: 공간이 바뀌면 새 공간의 현재 요금표를 적용한다', () async {
        await useCase.updateReservation(
          reservation: stored.copyWith(spaceOptionId: 'space-b'),
        );

        // 20,000 × 2시간 + 추가 인원 2명 × 1,000 × 2시간 = 44,000
        expect(capturedUpdate?.calculatedPrice, 44000);
        expect(capturedUpdate?.totalPrice, 39000);
        expect(capturedUpdate?.priceSetting, _weekdayHourlySetting(20000));
      });
    });
  });

  // =========================================================================
  // deleteReservation
  // =========================================================================

  group('deleteReservation', () {
    test('올바른 파라미터로 Repository를 호출한다', () async {
      when(
        () => mockReservationRepo.deleteReservation(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
        ),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.deleteReservation(
        storeId: 'store-123',
        reservationId: 'res-001',
      );

      result.fold((error) => fail(error.toString()), (_) {});
      verify(
        () => mockReservationRepo.deleteReservation(
          storeId: 'store-123',
          reservationId: 'res-001',
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // updateReservationStatus
  // =========================================================================

  group('updateReservationStatus', () {
    test('올바른 파라미터로 Repository를 호출한다', () async {
      when(
        () => mockReservationRepo.updateReservationStatus(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.canceled,
      );

      result.fold((error) => fail(error.toString()), (_) {});
      verify(
        () => mockReservationRepo.updateReservationStatus(
          storeId: 'store-123',
          reservationId: 'res-001',
          status: ReservationStatus.canceled,
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // watchReservationsByDateRange
  // =========================================================================

  group('watchReservationsByDateRange', () {
    final start = DateTime(2026, 5, 1);
    final end = DateTime(2026, 5, 31);

    test('유저 조회 실패 시 스트림이 에러를 방출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final stream = useCase.watchReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      await expectLater(stream, emitsError(isA<Exception>()));
    });

    test('유저가 null이면 스트림이 AuthUserNotFoundException을 방출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final stream = useCase.watchReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      await expectLater(stream, emitsError(isA<AuthUserNotFoundException>()));
    });

    test('유저 조회 성공 시 Repository 스트림을 그대로 전달한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.watchReservationsByDateRange(
          storeId: any(named: 'storeId'),
          currentUid: any(named: 'currentUid'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) => Stream.value([fakeReservation]));

      final stream = useCase.watchReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      await expectLater(stream, emits([fakeReservation]));
    });
  });
}
