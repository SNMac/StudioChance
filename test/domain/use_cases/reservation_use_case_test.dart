import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';

import '../../helpers/fake_entities.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockStoreRepository extends Mock implements StoreRepository {}

class FakeReservation extends Fake implements Reservation {}

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
    test('writer.user를 현재 로그인 유저로 교체하여 Repository를 호출한다', () async {
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

      expect(result.isRight(), true);
      expect(capturedReservation?.writer.user.id, fakeUser.id);
    });

    test('createReservation 시 writer.role은 원본 그대로 유지된다', () async {
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

      await useCase.createReservation(reservation: fakeReservation);

      expect(capturedReservation?.writer.role, UserRole.admin);
    });

    test('유저 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      expect(result.isLeft(), true);
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

      expect(result.isLeft(), true);
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

      expect(result.isLeft(), true);
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

      expect(result.isRight(), true);
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

      expect(result.isLeft(), true);
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

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // updateReservation
  // =========================================================================

  group('updateReservation', () {
    test('Repository.updateReservation을 그대로 위임한다', () async {
      when(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.updateReservation(
        reservation: fakeReservation,
      );

      expect(result.isRight(), true);
      verify(
        () => mockReservationRepo.updateReservation(
          reservation: fakeReservation,
        ),
      ).called(1);
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((_) async => left(Exception('수정 실패')));

      final result = await useCase.updateReservation(
        reservation: fakeReservation,
      );

      expect(result.isLeft(), true);
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

      expect(result.isRight(), true);
      verify(
        () => mockReservationRepo.deleteReservation(
          storeId: 'store-123',
          reservationId: 'res-001',
        ),
      ).called(1);
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(
        () => mockReservationRepo.deleteReservation(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
        ),
      ).thenAnswer((_) async => left(Exception('삭제 실패')));

      final result = await useCase.deleteReservation(
        storeId: 'store-123',
        reservationId: 'res-001',
      );

      expect(result.isLeft(), true);
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

      expect(result.isRight(), true);
      verify(
        () => mockReservationRepo.updateReservationStatus(
          storeId: 'store-123',
          reservationId: 'res-001',
          status: ReservationStatus.canceled,
        ),
      ).called(1);
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(
        () => mockReservationRepo.updateReservationStatus(
          storeId: any(named: 'storeId'),
          reservationId: any(named: 'reservationId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => left(Exception('상태 변경 실패')));

      final result = await useCase.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.canceled,
      );

      expect(result.isLeft(), true);
    });
  });
}
