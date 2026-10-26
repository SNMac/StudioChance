import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';

import '../../helpers/fake_data.dart';
import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

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
      when(() => mockReservationDs.createReservation(any()))
          .thenAnswer((_) async => fakeReservationModel);

      final result = await repository.createReservation(
        reservation: fakeReservation,
      );

      expectRight(result);
      final reservation = expectRight(result);
      expect(reservation.id, fakeReservationModel.id);
      expect(reservation.customerName, fakeReservationModel.customerName);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(() => mockReservationDs.createReservation(any()))
          .thenThrow(Exception('Firestore 오류'));

      final result = await repository.createReservation(
        reservation: fakeReservation,
      );

      expectLeft(result);
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

      expectRight(result);
      expect(expectRight(result), isEmpty);
      verifyNever(() => mockUserDs.getUser(any()));
    });

    test('정상 조회 시 엔티티 목록을 반환하고 StoreSummary와 writerRole을 올바르게 반영한다', () async {
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => [fakeReservationModel]);
      when(() => mockUserDs.getUser('user-123'))
          .thenAnswer((_) async => fakeUserModel);
      when(() => mockUserDs.getUserIncludingDeleted('user-123'))
          .thenAnswer((_) async => fakeUserModel);

      final result = await repository.getReservationsByDateRange(
        storeId: 'store-123',
        currentUid: 'user-123',
        start: start,
        end: end,
      );

      expectRight(result);
      final reservations = expectRight(result);
      expect(reservations.length, 1);
      expect(reservations.first.id, 'res-001');
      expect(
        reservations.first.storeSummary.color,
        fakeUserModel.storeById['store-123']!.color,
      );
      expect(reservations.first.writer.role, fakeReservationModel.writerRole);
    });

    // 계정을 삭제해도 예약은 점포에 남는다 (ADR-0005)
    test('작성자가 삭제된 계정이어도 목록 조회가 실패하지 않는다', () async {
      final deletedWriterModel = fakeReservationModel.copyWith(
        id: 'res-deleted-writer',
        writerId: 'deleted-uid',
      );
      when(
        () => mockReservationDs.getReservationsByDateRange(any(), any(), any()),
      ).thenAnswer((_) async => [fakeReservationModel, deletedWriterModel]);
      when(() => mockUserDs.getUser('user-123'))
          .thenAnswer((_) async => fakeUserModel);
      when(() => mockUserDs.getUserIncludingDeleted('user-123'))
          .thenAnswer((_) async => fakeUserModel);
      when(() => mockUserDs.getUserIncludingDeleted('deleted-uid')).thenAnswer(
        (_) async => UserModel.deleted(id: 'deleted-uid', nickname: '떠난 직원'),
      );

      final result = await repository.getReservationsByDateRange(
        storeId: 'store-123',
        currentUid: 'user-123',
        start: start,
        end: end,
      );

      final writer = expectRight(result).last.writer.user;
      expect(writer.isDeleted, true);
      expect(writer.nickname, '떠난 직원');
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

      expectLeft(result);
    });
  });

  // =========================================================================
  // updateReservation
  // =========================================================================

  group('updateReservation', () {
    test('올바른 storeId와 reservationId로 DataSource를 호출한다', () async {
      when(() => mockReservationDs.updateReservation(any(), any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.updateReservation(
        reservation: fakeReservation,
      );

      expectRight(result);
      verify(
        () => mockReservationDs.updateReservation(
          fakeReservation.storeSummary.id,
          fakeReservation.id,
          any(),
        ),
      ).called(1);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(() => mockReservationDs.updateReservation(any(), any(), any()))
          .thenThrow(Exception('업데이트 실패'));

      final result = await repository.updateReservation(
        reservation: fakeReservation,
      );

      expectLeft(result);
    });
  });

  // =========================================================================
  // moveReservation
  // =========================================================================

  group('moveReservation', () {
    test('원래 점포 id와 이동할 점포·작성자가 담긴 모델로 DataSource를 호출한다', () async {
      when(() => mockReservationDs.moveReservation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.moveReservation(
        reservation: fakeReservation,
        fromStoreId: 'store-old',
      );

      expectRight(result);
      final model =
          verify(
                () => mockReservationDs.moveReservation(
                  'store-old',
                  captureAny(),
                ),
              ).captured.single
              as ReservationModel;
      expect(model.id, fakeReservation.id);
      expect(model.storeId, fakeReservation.storeSummary.id);
      expect(model.writerId, fakeReservation.writer.user.id);
      expect(model.writerRole, fakeReservation.writer.role);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(() => mockReservationDs.moveReservation(any(), any()))
          .thenThrow(Exception('이동 실패'));

      final result = await repository.moveReservation(
        reservation: fakeReservation,
        fromStoreId: 'store-old',
      );

      expectLeft(result);
    });
  });

  // =========================================================================
  // deleteReservation
  // =========================================================================

  group('deleteReservation', () {
    test('올바른 storeId와 reservationId로 DataSource를 호출한다', () async {
      when(() => mockReservationDs.deleteReservation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteReservation(
        storeId: 'store-123',
        reservationId: 'res-001',
      );

      expectRight(result);
      verify(() => mockReservationDs.deleteReservation('store-123', 'res-001'))
          .called(1);
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(() => mockReservationDs.deleteReservation(any(), any()))
          .thenThrow(Exception('삭제 실패'));

      final result = await repository.deleteReservation(
        storeId: 'store-123',
        reservationId: 'res-001',
      );

      expectLeft(result);
    });
  });

  // =========================================================================
  // updateReservationStatus
  // =========================================================================

  group('updateReservationStatus', () {
    test('status를 대문자 JSON 값(jsonValue)으로 DataSource에 전달한다', () async {
      Map<String, dynamic>? capturedData;
      when(() => mockReservationDs.updateReservation(any(), any(), any()))
          .thenAnswer((invocation) async {
            capturedData =
                invocation.positionalArguments[2] as Map<String, dynamic>;
          });

      final result = await repository.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.confirmed,
      );

      expectRight(result);
      expect(capturedData?['status'], 'CONFIRMED');
    });

    test('DataSource 실패 시 left(exception)를 반환한다', () async {
      when(() => mockReservationDs.updateReservation(any(), any(), any()))
          .thenThrow(Exception('상태 변경 실패'));

      final result = await repository.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.canceled,
      );

      expectLeft(result);
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
      when(() => mockUserDs.getUser('user-123'))
          .thenAnswer((_) async => fakeUserModel);
      when(() => mockUserDs.getUserIncludingDeleted('different-writer-id'))
          .thenAnswer((_) async => fakeUserModel);

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

    // 건너뛰면 캘린더에서 예약이 사라진다
    test('작성자 문서가 없는 예약도 건너뛰지 않고 삭제된 계정으로 채운다', () async {
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
      when(() => mockUserDs.getUser('user-123'))
          .thenAnswer((_) async => fakeUserModel);
      when(() => mockUserDs.getUserIncludingDeleted('user-123'))
          .thenAnswer((_) async => fakeUserModel);
      when(() => mockUserDs.getUserIncludingDeleted('ghost-uid'))
          .thenAnswer((_) async => null);

      final result = await repository
          .watchReservationsByDateRange(
            storeId: 'store-123',
            currentUid: 'user-123',
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 5, 31),
          )
          .first;

      expect(result.map((r) => r.id), ['res-001', 'res-missing-writer']);
      expect(result.last.writer.user.isDeleted, true);
    });
  });
}
