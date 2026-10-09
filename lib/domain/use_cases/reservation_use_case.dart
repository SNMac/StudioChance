import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
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
  /// 내부적으로 최초 구독 시점에 현재 로그인 유저를 1회 조회하여 이후
  /// Repository 스트림에 고정 전달한다. 조회 시점에 로그인 상태가 아직
  /// 확정되지 않았다면([AuthUserNotFoundException]) 스트림은 에러를 1회
  /// 방출한 뒤 영구 종료된다 — 자동 재구독은 하지 않는다.
  ///
  /// 따라서 호출부는 인증 상태가 확정된 이후에만 구독을 시작해야 한다.
  /// (`home_reservations_provider.dart`의 `homeReservations`는
  /// `currentUserProvider.future`를 먼저 await한 뒤 구독을 시작하여
  /// 이 경쟁 조건을 회피한다.)
  ///
  /// 에러는 스트림 에러로 전파된다.
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required DateTime start,
    required DateTime end,
  });

  /// 예약 정보 수정
  ///
  /// 가격은 저장된 예약의 요금표 스냅샷([Reservation.priceSetting])으로 재계산하므로,
  /// 점포 요금이 바뀌어도 예약 가격이 저절로 바뀌지 않는다. 다음 경우에만 점포의
  /// 현재 요금표로 재계산하고 스냅샷을 교체한다.
  /// - [applyCurrentPrice]가 true (사용자가 현재 요금 적용을 선택)
  /// - 점포나 공간이 바뀜 (원래 스냅샷은 다른 공간의 요금표)
  /// - 저장된 스냅샷이 없음
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
    bool applyCurrentPrice = false,
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

class ReservationUseCaseImpl implements ReservationUseCase {
  final ReservationRepository _reservationRepository;
  final UserRepository _userRepository;
  final StoreRepository _storeRepository;
  final Logger _logger = Logger();

  ReservationUseCaseImpl({
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
    // 새 예약에는 저장된 요금표가 없다 — 화면이 보낸 요금표는 쓰지 않는다
    final pricedResult = await _applyCurrentPrice(
      reservation.copyWith(priceSetting: null),
    );

    return pricedResult.fold(
      (error) => Future.value(left(error)),
      (priced) =>
          getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
            final reservationWithWriter = priced.copyWith(
              writer: priced.writer.copyWith(user: currentUser),
            );

            return TaskEither(
              () => _reservationRepository.createReservation(
                reservation: reservationWithWriter,
              ),
            );
          }).run(),
    );
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
    bool applyCurrentPrice = false,
  }) async {
    final pricedResult = await getCurrentUserOrThrow(_userRepository)
        .flatMap(
          (currentUser) => TaskEither(
            () => _reservationRepository.getReservation(
              storeId: reservation.storeSummary.id,
              reservationId: reservation.id,
              currentUid: currentUser.id,
            ),
          ),
        )
        .flatMap((stored) {
          // 화면이 보낸 요금표는 신뢰하지 않고 저장된 예약의 요금표로 바꿔 둔다 —
          // 현재 요금표를 구하지 못해 그대로 저장되는 경로에서도 지켜지도록
          final base = reservation.copyWith(priceSetting: stored?.priceSetting);
          final keepsSnapshot =
              !applyCurrentPrice &&
              stored != null &&
              stored.keepsPriceSettingFor(base);
          return keepsSnapshot
              ? TaskEither.right(_applyPriceSetting(base, base.priceSetting!))
              : TaskEither(() => _applyCurrentPrice(base));
        })
        .run();

    return pricedResult.fold(
      (error) => Future.value(left(error)),
      (priced) => _reservationRepository.updateReservation(reservation: priced),
    );
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

  @override
  Future<Either<Exception, int>> getReservationCountByCustomer({
    required String storeId,
    required String customerName,
    required String customerPhone,
  }) {
    return _reservationRepository.getReservationCountByCustomer(
      storeId: storeId,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Store의 현재 PriceSetting으로 가격을 계산하고, 그 요금표를 스냅샷으로 저장한 예약 반환.
  ///
  /// Store 조회 자체가 실패(네트워크 등)하면 에러를 그대로 전파한다.
  /// Store가 존재하지 않거나 공간(요금표)이 없으면 기존 값을 유지한다.
  Future<Either<Exception, Reservation>> _applyCurrentPrice(
    Reservation reservation,
  ) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    return storeResult.fold(
      (error) {
        _logger.w(
          '가격 계산을 위한 Store 조회 실패 — storeId: ${reservation.storeSummary.id}',
          error: error,
        );
        return left(error);
      },
      (store) {
        if (store == null) return right(reservation);

        final priceSetting = store.priceSettingForSpace(
          reservation.spaceOptionId,
        );
        if (priceSetting == null) return right(reservation);

        return right(_applyPriceSetting(reservation, priceSetting));
      },
    );
  }

  /// [priceSetting]으로 calculatedPrice, totalPrice를 계산하고 스냅샷으로 함께 담은 예약 반환.
  Reservation _applyPriceSetting(
    Reservation reservation,
    PriceSetting priceSetting,
  ) {
    final calculatedPrice = priceSetting.calculatePrice(
      start: reservation.startTime,
      end: reservation.endTime,
      headCount: reservation.headCount,
      isAllDay: reservation.isAllDay,
      isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달
    );

    return reservation.copyWith(
      priceSetting: priceSetting,
      calculatedPrice: calculatedPrice,
      totalPrice: calculatedPrice + reservation.priceAdjustment,
    );
  }
}
