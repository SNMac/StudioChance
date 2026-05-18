import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/use_cases/use_case_helpers.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

abstract interface class ReservationUseCase {
  /// 예약 생성
  ///
  /// writerId는 현재 로그인된 사용자로 자동 설정됩니다.
  Future<Either<Exception, Reservation>> createReservation({
    required Reservation reservation,
  });

  /// 예약 단일 조회
  Future<Either<Exception, Reservation?>> getReservation({
    required String storeId,
    required String reservationId,
  });

  /// 날짜 범위로 예약 목록 조회
  ///
  /// [start] 이상 [end] 미만의 startTime을 가진 예약을 반환합니다.
  Future<Either<Exception, List<Reservation>>> getReservationsByDateRange({
    required String storeId,
    required DateTime start,
    required DateTime end,
  });

  /// 날짜 범위 예약 실시간 구독
  ///
  /// 에러는 스트림 에러로 전파됩니다.
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
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
}

class ReservationUseCaseImpl implements ReservationUseCase {
  final ReservationRepository _reservationRepository;
  final UserRepository _userRepository;
  final StoreRepository _storeRepository;

  const ReservationUseCaseImpl({
    required ReservationRepository reservationRepository,
    required UserRepository userRepository,
    required StoreRepository storeRepository,
  }) : _reservationRepository = reservationRepository,
       _userRepository = userRepository,
       _storeRepository = storeRepository;

  @override
  Future<Either<Exception, Reservation>> createReservation({
    required Reservation reservation,
  }) async {
    final priced = await _applyCalculatedPrice(reservation);

    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      final reservationWithWriter = priced.copyWith(
        writer: priced.writer.copyWith(user: currentUser),
      );

      return TaskEither(
        () => _reservationRepository.createReservation(
          reservation: reservationWithWriter,
        ),
      );
    }).run();
  }

  @override
  Future<Either<Exception, Reservation?>> getReservation({
    required String storeId,
    required String reservationId,
  }) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      return TaskEither(
        () => _reservationRepository.getReservation(
          storeId: storeId,
          reservationId: reservationId,
          currentUid: currentUser.id,
        ),
      );
    }).run();
  }

  @override
  Future<Either<Exception, List<Reservation>>> getReservationsByDateRange({
    required String storeId,
    required DateTime start,
    required DateTime end,
  }) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      return TaskEither(
        () => _reservationRepository.getReservationsByDateRange(
          storeId: storeId,
          currentUid: currentUser.id,
          start: start,
          end: end,
        ),
      );
    }).run();
  }

  @override
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required DateTime start,
    required DateTime end,
  }) {
    return Stream.fromFuture(getCurrentUserOrThrow(_userRepository).run())
        .asyncExpand(
          (result) => result.fold(
            (error) => Stream.error(error),
            (user) => _reservationRepository.watchReservationsByDateRange(
              storeId: storeId,
              currentUid: user.id,
              start: start,
              end: end,
            ),
          ),
        );
  }

  @override
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
  }) async {
    final priced = await _applyCalculatedPrice(reservation);
    return _reservationRepository.updateReservation(reservation: priced);
  }

  @override
  Future<Either<Exception, void>> deleteReservation({
    required String storeId,
    required String reservationId,
  }) {
    return _reservationRepository.deleteReservation(
      storeId: storeId,
      reservationId: reservationId,
    );
  }

  @override
  Future<Either<Exception, void>> updateReservationStatus({
    required String storeId,
    required String reservationId,
    required ReservationStatus status,
  }) {
    return _reservationRepository.updateReservationStatus(
      storeId: storeId,
      reservationId: reservationId,
      status: status,
    );
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Store의 PriceSetting으로 calculatedPrice, totalPrice를 계산하여 반영한 예약 반환.
  ///
  /// Store 조회 실패 또는 PriceSetting 매칭 실패 시 기존 값을 유지한다.
  Future<Reservation> _applyCalculatedPrice(Reservation reservation) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    final store = storeResult.toOption().toNullable();
    if (store == null) return reservation;

    final calculatedPrice = store.priceSettings.calculatePrice(
      start: reservation.startTime,
      end: reservation.endTime,
      headCount: reservation.headCount,
      isAllDay: reservation.isAllDay,
    );

    return reservation.copyWith(
      calculatedPrice: calculatedPrice,
      totalPrice: calculatedPrice + reservation.priceAdjustment,
    );
  }
}
