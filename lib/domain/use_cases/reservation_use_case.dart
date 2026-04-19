import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

part 'reservation_use_case.g.dart';

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

  const ReservationUseCaseImpl({
    required ReservationRepository reservationRepository,
    required UserRepository userRepository,
  }) : _reservationRepository = reservationRepository,
       _userRepository = userRepository;

  @override
  Future<Either<Exception, Reservation>> createReservation({
    required Reservation reservation,
  }) {
    return _getCurrentUser().flatMap((currentUser) {
      final reservationWithWriter = reservation.copyWith(
        writer: reservation.writer.copyWith(user: currentUser),
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
    return _getCurrentUser().flatMap((currentUser) {
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
    return _getCurrentUser().flatMap((currentUser) {
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
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
  }) {
    return _reservationRepository.updateReservation(
      reservation: reservation,
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

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// 현재 로그인한 유저를 가져오는 `TaskEither`
  TaskEither<Exception, User> _getCurrentUser() {
    return TaskEither.tryCatch(() async {
      final result = await _userRepository.getCurrentUser();
      return result.fold((left) => throw left, (right) {
        if (right == null) {
          throw AuthUserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
        }
        return right;
      });
    }, (error, stackTrace) => error is Exception ? error : Exception(error));
  }
}

@riverpod
ReservationUseCase reservationUseCase(Ref ref) {
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return ReservationUseCaseImpl(
    reservationRepository: reservationRepository,
    userRepository: userRepository,
  );
}
