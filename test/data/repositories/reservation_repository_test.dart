import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/reservation_data_source.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';

import '../../helpers/fake_data.dart';

class MockReservationDataSource extends Mock implements ReservationDataSource {}

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

class FakeReservationModel extends Fake implements ReservationModel {}

void main() {
  late ReservationRepositoryImpl repository;
  late MockReservationDataSource mockReservationDs;
  late MockStoreDataSource mockStoreDs;
  late MockUserDataSource mockUserDs;

  setUpAll(() {
    registerFallbackValue(FakeReservationModel());
  });

  setUp(() {
    mockReservationDs = MockReservationDataSource();
    mockStoreDs = MockStoreDataSource();
    mockUserDs = MockUserDataSource();
    repository = ReservationRepositoryImpl(
      reservationDataSource: mockReservationDs,
      storeDataSource: mockStoreDs,
      userDataSource: mockUserDs,
    );
  });

  // =========================================================================
  // createReservation
  // =========================================================================

  group('createReservation', () {
    test('DataSource 반환 모델로 엔티티를 생성하여 right로 반환한다', () async {
      when(
        () => mockReservationDs.createReservation(any()),
      ).thenAnswer((_) async => fakeReservationModel);

      final result = await repository.createReservation(
        reservation: fakeReservation,
      );

      expect(result.isRight(), true);
      final reservation = result.getRight().toNullable()!;
      expect(reservation.id, fakeReservationModel.id);
      expect(reservation.customerName, fakeReservationModel.customerName);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockReservationDs.createReservation(any()),
      ).thenThrow(Exception('Firestore 오류'));

      final result = await repository.createReservation(
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

    test('빈 목록이면 DataSource 추가 조회 없이 right([])를 반환한다', () async {
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => []);

      final result = await repository.getReservationsByDateRange(
        storeId: 'store-123',
        currentUid: 'user-123',
        start: start,
        end: end,
      );

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), isEmpty);
      verifyNever(() => mockStoreDs.getStore(any()));
      verifyNever(() => mockUserDs.getUser(any()));
    });

    test('정상 조회 시 엔티티 목록을 반환하고 StoreSummary에 currentUid 색상을 반영한다', () async {
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => [fakeReservationModel]);
      when(
        () => mockStoreDs.getStore('store-123'),
      ).thenAnswer((_) async => fakeStoreModel);
      when(
        () => mockUserDs.getUser('user-123'),
      ).thenAnswer((_) async => fakeUserModel);

      final result = await repository.getReservationsByDateRange(
        storeId: 'store-123',
        currentUid: 'user-123',
        start: start,
        end: end,
      );

      expect(result.isRight(), true);
      final reservations = result.getRight().toNullable()!;
      expect(reservations.length, 1);
      expect(reservations.first.id, 'res-001');
      expect(
        reservations.first.storeSummary.color,
        fakeUserModel.storeById['store-123']!.color,
      );
      expect(reservations.first.writer.role, fakeStoreModel.memberById['user-123']!.role);
    });

    test('StoreDataSource가 null을 반환하면 left(exception)를 반환한다', () async {
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => [fakeReservationModel]);
      when(
        () => mockStoreDs.getStore(any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockUserDs.getUser(any()),
      ).thenAnswer((_) async => fakeUserModel);

      final result = await repository.getReservationsByDateRange(
        storeId: 'store-123',
        currentUid: 'user-123',
        start: start,
        end: end,
      );

      expect(result.isLeft(), true);
    });

    test('ReservationDataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenThrow(Exception('Firestore 오류'));

      final result = await repository.getReservationsByDateRange(
        storeId: 'store-123',
        currentUid: 'user-123',
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
    test('올바른 storeId와 reservationId로 DataSource를 호출한다', () async {
      when(
        () => mockReservationDs.updateReservation(any(), any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.updateReservation(
        reservation: fakeReservation,
      );

      expect(result.isRight(), true);
      verify(
        () => mockReservationDs.updateReservation(
          fakeReservation.storeSummary.id,
          fakeReservation.id,
          any(),
        ),
      ).called(1);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockReservationDs.updateReservation(any(), any(), any()),
      ).thenThrow(Exception('업데이트 실패'));

      final result = await repository.updateReservation(
        reservation: fakeReservation,
      );

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // deleteReservation
  // =========================================================================

  group('deleteReservation', () {
    test('올바른 storeId와 reservationId로 DataSource를 호출한다', () async {
      when(
        () => mockReservationDs.deleteReservation(any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.deleteReservation(
        storeId: 'store-123',
        reservationId: 'res-001',
      );

      expect(result.isRight(), true);
      verify(
        () => mockReservationDs.deleteReservation('store-123', 'res-001'),
      ).called(1);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockReservationDs.deleteReservation(any(), any()),
      ).thenThrow(Exception('삭제 실패'));

      final result = await repository.deleteReservation(
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
    test('status.name을 포함한 데이터로 DataSource를 호출한다', () async {
      Map<String, dynamic>? capturedData;
      when(
        () => mockReservationDs.updateReservation(any(), any(), any()),
      ).thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[2] as Map<String, dynamic>;
      });

      final result = await repository.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.confirmed,
      );

      expect(result.isRight(), true);
      expect(capturedData?['status'], ReservationStatus.confirmed.name);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockReservationDs.updateReservation(any(), any(), any()),
      ).thenThrow(Exception('상태 변경 실패'));

      final result = await repository.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.canceled,
      );

      expect(result.isLeft(), true);
    });
  });
}
