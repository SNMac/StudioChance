import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/exceptions/reservation_exceptions.dart';
import 'package:studio_chance/data/data_sources/reservation_data_source.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/domain/enums/payment_method.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

import '../../helpers/firestore_emulator_helper.dart';

ReservationModel _testReservation({
  String? id,
  required String storeId,
  DateTime? startTime,
  DateTime? endTime,
  String customerName = '홍길동',
  String customerPhone = '010-1234-5678',
}) {
  return ReservationModel(
    id: id ?? FirestoreEmulatorHelper.generateId(),
    storeId: storeId,
    writerId: 'user-test',
    status: ReservationStatus.confirmed,
    customerName: customerName,
    headCount: 2,
    customerPhone: customerPhone,
    memo: '테스트 메모',
    isAllDay: false,
    startTime: startTime ?? DateTime(2026, 6, 1, 10, 0),
    endTime: endTime ?? DateTime(2026, 6, 1, 12, 0),
    platform: ReservationPlatform.naver,
    paymentMethod: PaymentMethod.bankTransfer,
    calculatedPrice: 50000,
    priceAdjustment: 0,
    totalPrice: 50000,
    writerRole: UserRole.admin,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ReservationFirestoreDataSource dataSource;
  const storeId = 'test-store';

  setUp(() {
    fakeFirestore = FirestoreEmulatorHelper.create();
    dataSource = ReservationFirestoreDataSource(fakeFirestore);
  });

  // =========================================================================
  // createReservation
  // =========================================================================

  group('createReservation', () {
    test('문서를 생성하고 Firestore 생성 ID가 반영된 모델을 반환한다', () async {
      final reservation = _testReservation(storeId: storeId);

      final result = await dataSource.createReservation(reservation);

      expect(result.id, isNotEmpty);
      expect(result.customerName, reservation.customerName);
      expect(result.storeId, storeId);
    });

    test('생성된 문서를 Firestore에서 직접 조회할 수 있다', () async {
      final reservation = _testReservation(storeId: storeId);

      final created = await dataSource.createReservation(reservation);
      final doc = await fakeFirestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc(created.id)
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['customerName'], reservation.customerName);
    });

    test(
      'TimestampConverter: startTime/endTime이 Timestamp로 저장되고 DateTime으로 복원된다',
      () async {
        final startTime = DateTime(2026, 6, 15, 9, 30);
        final endTime = DateTime(2026, 6, 15, 11, 0);
        final reservation = _testReservation(
          storeId: storeId,
          startTime: startTime,
          endTime: endTime,
        );

        final created = await dataSource.createReservation(reservation);
        final fetched = await dataSource.getReservation(storeId, created.id);

        expect(fetched?.startTime, startTime);
        expect(fetched?.endTime, endTime);
      },
    );
  });

  // =========================================================================
  // getReservation
  // =========================================================================

  group('getReservation', () {
    test('존재하는 예약을 반환한다', () async {
      final reservation = _testReservation(storeId: storeId);
      final created = await dataSource.createReservation(reservation);

      final result = await dataSource.getReservation(storeId, created.id);

      expect(result, isNotNull);
      expect(result!.id, created.id);
      expect(result.customerName, reservation.customerName);
      expect(result.headCount, reservation.headCount);
    });

    test('존재하지 않는 ID로 조회하면 null을 반환한다', () async {
      final result = await dataSource.getReservation(storeId, 'nonexistent-id');

      expect(result, isNull);
    });
  });

  // =========================================================================
  // getReservationsByDateRange
  // =========================================================================

  group('getReservationsByDateRange', () {
    test('조회 범위 내 예약만 반환한다', () async {
      final inRange = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 6, 10),
        endTime: DateTime(2026, 6, 10, 2),
      );
      final outOfRange = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 7, 5),
        endTime: DateTime(2026, 7, 5, 2),
      );
      await dataSource.createReservation(inRange);
      await dataSource.createReservation(outOfRange);

      final result = await dataSource.getReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );

      expect(result.length, 1);
      expect(result.first.customerName, inRange.customerName);
    });

    test('start 경계(이상)의 예약을 포함하고 end 경계(미만)의 예약을 제외한다', () async {
      final atStart = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 6, 1),
        endTime: DateTime(2026, 6, 1, 2),
      );
      final atEnd = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 7, 1),
        endTime: DateTime(2026, 7, 1, 2),
      );
      await dataSource.createReservation(atStart);
      await dataSource.createReservation(atEnd);

      final result = await dataSource.getReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );

      expect(result.length, 1);
      expect(result.first.startTime, DateTime(2026, 6, 1));
    });

    test('startTime 오름차순으로 정렬된 목록을 반환한다', () async {
      final later = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 6, 20),
        endTime: DateTime(2026, 6, 20, 2),
      );
      final earlier = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 6, 5),
        endTime: DateTime(2026, 6, 5, 2),
      );
      await dataSource.createReservation(later);
      await dataSource.createReservation(earlier);

      final result = await dataSource.getReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );

      expect(result.length, 2);
      expect(result[0].startTime.isBefore(result[1].startTime), true);
    });

    test('범위 내 예약이 없으면 빈 목록을 반환한다', () async {
      final result = await dataSource.getReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );

      expect(result, isEmpty);
    });
  });

  // =========================================================================
  // watchReservationsByDateRange
  // =========================================================================

  group('watchReservationsByDateRange', () {
    test('범위 내 예약 목록을 스트림으로 방출한다', () async {
      final reservation = _testReservation(
        storeId: storeId,
        startTime: DateTime(2026, 6, 10),
        endTime: DateTime(2026, 6, 10, 2),
      );
      await dataSource.createReservation(reservation);

      final stream = dataSource.watchReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.customerName, reservation.customerName);
    });

    test('범위 내 예약이 없으면 빈 목록을 방출한다', () async {
      final stream = dataSource.watchReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('파싱 실패 시 도메인 예외로 변환되어 스트림 에러로 방출된다', () async {
      // customerName 등 필수 필드가 없는 손상된 문서를 직접 주입하여
      // ReservationModel.fromJson이 TypeError를 던지도록 유도한다.
      await fakeFirestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc('broken-doc')
          .set({
        'startTime': Timestamp.fromDate(DateTime(2026, 6, 15)),
      });

      final stream = dataSource.watchReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );

      await expectLater(
        stream,
        emitsError(isA<ReservationDataParsingException>()),
      );
    });
  });

  // =========================================================================
  // updateReservation
  // =========================================================================

  group('updateReservation', () {
    test('지정 필드를 업데이트한다', () async {
      final reservation = _testReservation(storeId: storeId);
      final created = await dataSource.createReservation(reservation);

      await dataSource.updateReservation(
        storeId,
        created.id,
        {'customerName': '김영희', 'headCount': 5},
      );

      final updated = await dataSource.getReservation(storeId, created.id);
      expect(updated?.customerName, '김영희');
      expect(updated?.headCount, 5);
    });

    test('업데이트 후 기존 필드는 변경되지 않는다', () async {
      final reservation = _testReservation(storeId: storeId);
      final created = await dataSource.createReservation(reservation);

      await dataSource.updateReservation(
        storeId,
        created.id,
        {'customerName': '김영희'},
      );

      final updated = await dataSource.getReservation(storeId, created.id);
      expect(updated?.customerPhone, reservation.customerPhone);
      expect(updated?.memo, reservation.memo);
      expect(updated?.totalPrice, reservation.totalPrice);
    });
  });

  // =========================================================================
  // deleteReservation
  // =========================================================================

  group('deleteReservation', () {
    test('예약 문서를 삭제한다', () async {
      final reservation = _testReservation(storeId: storeId);
      final created = await dataSource.createReservation(reservation);

      await dataSource.deleteReservation(storeId, created.id);

      final result = await dataSource.getReservation(storeId, created.id);
      expect(result, isNull);
    });

    test('삭제 후 Firestore 문서가 존재하지 않는다', () async {
      final reservation = _testReservation(storeId: storeId);
      final created = await dataSource.createReservation(reservation);

      await dataSource.deleteReservation(storeId, created.id);

      final doc = await fakeFirestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc(created.id)
          .get();
      expect(doc.exists, false);
    });
  });

  // =========================================================================
  // getReservationCountByCustomer
  // =========================================================================

  group('getReservationCountByCustomer', () {
    test('동일 고객의 예약 수를 반환한다', () async {
      const customerName = '홍길동';
      const customerPhone = '010-1111-2222';

      await dataSource.createReservation(
        _testReservation(
          storeId: storeId,
          customerName: customerName,
          customerPhone: customerPhone,
          startTime: DateTime(2026, 6, 1),
          endTime: DateTime(2026, 6, 1, 2),
        ),
      );
      await dataSource.createReservation(
        _testReservation(
          storeId: storeId,
          customerName: customerName,
          customerPhone: customerPhone,
          startTime: DateTime(2026, 6, 5),
          endTime: DateTime(2026, 6, 5, 2),
        ),
      );

      final count = await dataSource.getReservationCountByCustomer(
        storeId,
        customerName,
        customerPhone,
      );

      expect(count, 2);
    });

    test('다른 고객의 예약은 집계에 포함되지 않는다', () async {
      await dataSource.createReservation(
        _testReservation(
          storeId: storeId,
          customerName: '다른고객',
          customerPhone: '010-9999-8888',
        ),
      );

      final count = await dataSource.getReservationCountByCustomer(
        storeId,
        '홍길동',
        '010-1111-2222',
      );

      expect(count, 0);
    });

    test('예약이 없으면 0을 반환한다', () async {
      final count = await dataSource.getReservationCountByCustomer(
        storeId,
        '홍길동',
        '010-1111-2222',
      );

      expect(count, 0);
    });
  });
}
