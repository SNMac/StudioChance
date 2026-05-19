import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';

abstract interface class ReservationRepository {
  /// 예약 생성
  ///
  /// [reservation]의 writerId는 현재 로그인된 사용자 ID여야 합니다.
  Future<Either<Exception, Reservation>> createReservation({
    required Reservation reservation,
  });

  /// 예약 단일 조회
  ///
  /// [currentUid]: StoreSummary의 color를 조회하기 위한 현재 사용자 ID
  Future<Either<Exception, Reservation?>> getReservation({
    required String storeId,
    required String reservationId,
    required String currentUid,
  });

  /// 날짜 범위로 예약 목록 조회
  ///
  /// [start] 이상 [end] 미만의 startTime을 가진 예약을 반환합니다.
  /// [currentUid]: StoreSummary의 color를 조회하기 위한 현재 사용자 ID
  Future<Either<Exception, List<Reservation>>> getReservationsByDateRange({
    required String storeId,
    required String currentUid,
    required DateTime start,
    required DateTime end,
  });

  /// 날짜 범위 예약 실시간 구독
  ///
  /// 에러는 스트림 에러로 전파됩니다.
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required String currentUid,
    required DateTime start,
    required DateTime end,
  });

  /// 예약 정보 수정
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
  });

  /// 예약 삭제
  Future<Either<Exception, void>> deleteReservation({
    required String storeId,
    required String reservationId,
  });

  /// 예약 상태 변경
  Future<Either<Exception, void>> updateReservationStatus({
    required String storeId,
    required String reservationId,
    required ReservationStatus status,
  });

  /// 동일 고객(예약자명 + 연락처)의 해당 점포 예약 수 조회
  Future<Either<Exception, int>> getReservationCountByCustomer({
    required String storeId,
    required String customerName,
    required String customerPhone,
  });
}
