import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/reservation_exceptions.dart';
import 'package:studio_chance/data/data_sources/firestore_data_source_base.dart';
import 'package:studio_chance/data/models/reservation_model.dart';

part 'reservation_data_source.g.dart';

abstract interface class ReservationDataSource {
  /// 예약 생성
  ///
  /// Firestore 경로: `stores/{storeId}/reservations/{reservationId}`
  Future<ReservationModel> createReservation(ReservationModel reservation);

  /// 예약 단일 조회
  Future<ReservationModel?> getReservation(
    String storeId,
    String reservationId,
  );

  /// 날짜 범위로 예약 목록 조회
  ///
  /// [start] 이상 [end] 미만의 startTime을 가진 예약을 반환합니다.
  Future<List<ReservationModel>> getReservationsByDateRange(
    String storeId,
    DateTime start,
    DateTime end,
  );

  /// 예약 정보 수정
  Future<void> updateReservation(
    String storeId,
    String reservationId,
    Map<String, dynamic> data,
  );

  /// 예약 삭제
  Future<void> deleteReservation(String storeId, String reservationId);
}

class ReservationFirestoreDataSource extends FirestoreDataSourceBase
    implements ReservationDataSource {
  final FirebaseFirestore _firestore;

  ReservationFirestoreDataSource(this._firestore);

  @override
  String get errorLogTag => 'Reservation Firestore Error';

  @override
  bool isDomainException(Object e) => e is ReservationException;

  @override
  Exception buildParsingException(String message) =>
      ReservationDataParsingException(message: message);

  @override
  Exception mapFirebaseCode(String code, String message) => switch (code) {
    'permission-denied' || 'unauthenticated' =>
      ReservationPermissionDeniedException(message: message, code: code),
    'not-found' => ReservationNotFoundException(message: message, code: code),
    'resource-exhausted' =>
      ReservationResourceExhaustedException(message: message, code: code),
    'unavailable' || 'deadline-exceeded' =>
      ReservationNetworkException(message: message, code: code),
    'aborted' || 'failed-precondition' =>
      ReservationTransactionException(message: message, code: code),
    'cancelled' =>
      ReservationCancelledException(message: message, code: code),
    _ => ReservationUnknownException(message: message, code: code),
  };

  CollectionReference<Map<String, dynamic>> _reservationsRef(String storeId) {
    return _firestore
        .collection('stores')
        .doc(storeId)
        .collection('reservations');
  }

  @override
  Future<ReservationModel> createReservation(
    ReservationModel reservation,
  ) async {
    try {
      final docRef = _reservationsRef(reservation.storeId).doc();

      final json = reservation.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(json);

      return reservation.copyWith(id: docRef.id);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<ReservationModel?> getReservation(
    String storeId,
    String reservationId,
  ) async {
    try {
      final docSnapshot = await _reservationsRef(storeId).doc(reservationId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        return ReservationModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<List<ReservationModel>> getReservationsByDateRange(
    String storeId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final querySnapshot = await _reservationsRef(storeId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startTime', isLessThan: Timestamp.fromDate(end))
          .orderBy('startTime')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReservationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateReservation(
    String storeId,
    String reservationId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updates = Map<String, dynamic>.from(data);
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _reservationsRef(storeId).doc(reservationId).update(updates);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> deleteReservation(
    String storeId,
    String reservationId,
  ) async {
    try {
      await _reservationsRef(storeId).doc(reservationId).delete();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

}

@Riverpod(keepAlive: true)
ReservationDataSource reservationDataSource(Ref ref) {
  return ReservationFirestoreDataSource(FirebaseFirestore.instance);
}
