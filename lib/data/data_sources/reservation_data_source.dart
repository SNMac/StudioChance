import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/reservation_exceptions.dart';
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

class ReservationFirestoreDataSource implements ReservationDataSource {
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore;

  ReservationFirestoreDataSource(this._firestore);

  @override
  Future<ReservationModel> createReservation(
    ReservationModel reservation,
  ) async {
    try {
      final collectionRef = _firestore
          .collection('stores')
          .doc(reservation.storeId)
          .collection('reservations');

      final docRef = collectionRef.doc();

      final json = reservation.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(json);

      return reservation.copyWith(id: docRef.id);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<ReservationModel?> getReservation(
    String storeId,
    String reservationId,
  ) async {
    try {
      final docSnapshot = await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc(reservationId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        return ReservationModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<List<ReservationModel>> getReservationsByDateRange(
    String storeId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
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
      throw _handleFirestoreError(e);
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

      await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc(reservationId)
          .update(updates);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> deleteReservation(
    String storeId,
    String reservationId,
  ) async {
    try {
      await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc(reservationId)
          .delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  Exception _handleFirestoreError(Object e) {
    _logger.e('Reservation Firestore Error', error: e);

    if (e is ReservationException) return e;

    if (e is TypeError || e is FormatException) {
      return ReservationDataParsingException(
        message: '데이터 파싱에 실패했습니다.\n${e.toString()}',
      );
    }

    if (e is FirebaseException) {
      final msg = e.message ?? 'Cloud Firestore Error';
      final code = e.code;

      switch (code) {
        case 'permission-denied':
        case 'unauthenticated':
          return ReservationPermissionDeniedException(
            message: msg,
            code: code,
          );
        case 'not-found':
          return ReservationNotFoundException(message: msg, code: code);
        case 'resource-exhausted':
          return ReservationResourceExhaustedException(
            message: msg,
            code: code,
          );
        case 'unavailable':
        case 'deadline-exceeded':
          return ReservationNetworkException(message: msg, code: code);
        case 'aborted':
        case 'failed-precondition':
          return ReservationTransactionException(message: msg, code: code);
        case 'cancelled':
          return ReservationCancelledException(message: msg, code: code);
        default:
          return ReservationUnknownException(message: msg, code: code);
      }
    }

    return ReservationUnknownException(message: e.toString());
  }
}

@Riverpod(keepAlive: true)
ReservationDataSource reservationDataSource(Ref ref) {
  return ReservationFirestoreDataSource(FirebaseFirestore.instance);
}
