import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/reservation_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';

import '../../helpers/fake_data.dart';

class MockReservationDataSource extends Mock implements ReservationDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

class FakeReservationModel extends Fake implements ReservationModel {}

void main() {
  late ReservationRepositoryImpl repository;
  late MockReservationDataSource mockReservationDs;
  late MockUserDataSource mockUserDs;

  setUpAll(() {
    registerFallbackValue(FakeReservationModel());
  });

  setUp(() {
    mockReservationDs = MockReservationDataSource();
    mockUserDs = MockUserDataSource();
    repository = ReservationRepositoryImpl(
      reservationDataSource: mockReservationDs,
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
      verifyNever(() => mockUserDs.getUser(any()));
    });

    test('정상 조회 시 엔티티 목록을 반환하고 StoreSummary와 writerRole을 올바르게 반영한다', () async {
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => [fakeReservationModel]);
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
      expect(reservations.first.writer.role, fakeReservationModel.writerRole);
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
    test('status를 대문자 JSON 값(jsonValue)으로 DataSource에 전달한다', () async {
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
      expect(capturedData?['status'], 'CONFIRMED');
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

  // =========================================================================
  // watchReservationsByDateRange
  // =========================================================================

  group('watchReservationsByDateRange', () {
    test('currentUser는 스트림 구독 중 최초 1회만 조회된다', () async {
      // writer를 currentUser와 다르게 설정해야 currentUser 캐싱만 검증 가능
      final testReservationModel = fakeReservationModel.copyWith(
        writerId: 'different-writer-id',
      );
      when(
        () =>
            mockReservationDs.watchReservationsByDateRange(any(), any(), any()),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          [testReservationModel],
          [testReservationModel],
        ]),
      );
      when(
        () => mockUserDs.getUser('user-123'),
      ).thenAnswer((_) async => fakeUserModel);
      when(
        () => mockUserDs.getUser('different-writer-id'),
      ).thenAnswer((_) async => fakeUserModel);

      final results = await repository
          .watchReservationsByDateRange(
            storeId: 'store-123',
            currentUid: 'user-123',
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 5, 31),
          )
          .toList();

      expect(results.length, 2);
      verify(() => mockUserDs.getUser('user-123')).called(1);
    });

    test('작성자 정보를 찾을 수 없는 예약은 건너뛰고 나머지는 반환한다', () async {
      final missingWriterModel = fakeReservationModel.copyWith(
        id: 'res-missing-writer',
        writerId: 'ghost-uid',
      );
      when(
        () =>
            mockReservationDs.watchReservationsByDateRange(any(), any(), any()),
      ).thenAnswer(
        (_) => Stream.value([fakeReservationModel, missingWriterModel]),
      );
      when(
        () => mockUserDs.getUser('user-123'),
      ).thenAnswer((_) async => fakeUserModel);
      when(
        () => mockUserDs.getUser('ghost-uid'),
      ).thenAnswer((_) async => null);

      final result = await repository
          .watchReservationsByDateRange(
            storeId: 'store-123',
            currentUid: 'user-123',
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 5, 31),
          )
          .first;

      expect(result.length, 1);
      expect(result.first.id, 'res-001');
    });
  });
}
