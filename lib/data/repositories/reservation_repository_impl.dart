import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/reservation_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';

part 'reservation_repository_impl.g.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final Logger _logger = Logger();

  final ReservationDataSource _reservationDataSource;
  final UserDataSource _userDataSource;

  ReservationRepositoryImpl({
    required this._reservationDataSource,
    required this._userDataSource,
  });

  @override
  Future<Either<Exception, Reservation>> createReservation({
    required Reservation reservation,
  }) async {
    try {
      final model = ReservationModel.fromEntity(reservation);
      final createdModel = await _reservationDataSource.createReservation(
        model,
      );

      _logger.i('예약 생성 완료\nid: ${createdModel.id}');
      return right(
        createdModel.toEntity(reservation.storeSummary, reservation.writer),
      );
    } catch (e) {
      _logger.e('예약 생성 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, Reservation?>> getReservation({
    required String storeId,
    required String reservationId,
    required String currentUid,
  }) async {
    try {
      final model = await _reservationDataSource.getReservation(
        storeId,
        reservationId,
      );
      if (model == null) return right(null);

      final entity = await _buildReservationEntity(
        model: model,
        storeId: storeId,
        currentUid: currentUid,
      );
      return right(entity);
    } catch (e) {
      _logger.e('예약 조회 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, List<Reservation>>> getReservationsByDateRange({
    required String storeId,
    required String currentUid,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final models = await _reservationDataSource.getReservationsByDateRange(
        storeId,
        start,
        end,
      );

      if (models.isEmpty) return right([]);

      // 현재 사용자 정보 조회 (StoreSummary name/color 포함)
      final currentUserModel = await _userDataSource.getUser(currentUid);

      final storeSummary = _buildStoreSummary(
        storeId: storeId,
        currentUserModel: currentUserModel,
      );

      final writerById = await _getWritersById(models);

      final reservations = models.map((model) {
        return model.toEntity(
          storeSummary,
          _buildWriter(
            writerUserModel: writerById[model.writerId]!,
            writerRole: model.writerRole,
          ),
        );
      }).toList();

      return right(reservations);
    } catch (e) {
      _logger.e('예약 목록 조회 실패');
      return left(toException(e));
    }
  }

  @override
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required String currentUid,
    required DateTime start,
    required DateTime end,
  }) {
    // currentUser는 구독 도중 거의 변경되지 않으므로 스트림 최초 이벤트에서만 조회하고 캐싱한다.
    UserModel? cachedCurrentUserModel;

    return _reservationDataSource
        .watchReservationsByDateRange(storeId, start, end)
        .asyncMap((models) async {
          if (models.isEmpty) return <Reservation>[];

          cachedCurrentUserModel ??= await _userDataSource.getUser(currentUid);
          final storeSummary = _buildStoreSummary(
            storeId: storeId,
            currentUserModel: cachedCurrentUserModel,
          );

          final writerById = await _getWritersById(models);

          return models.map((model) {
            return model.toEntity(
              storeSummary,
              _buildWriter(
                writerUserModel: writerById[model.writerId]!,
                writerRole: model.writerRole,
              ),
            );
          }).toList();
        });
  }

  @override
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
  }) async {
    try {
      final model = ReservationModel.fromEntity(reservation);
      final json = model.toUpdateJson();

      await _reservationDataSource.updateReservation(
        reservation.storeSummary.id,
        reservation.id,
        json,
      );

      _logger.i('예약 수정 완료\nid: ${reservation.id}');
      return right(null);
    } catch (e) {
      _logger.e('예약 수정 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> moveReservation({
    required Reservation reservation,
    required String fromStoreId,
  }) async {
    try {
      await _reservationDataSource.moveReservation(
        fromStoreId,
        ReservationModel.fromEntity(reservation),
      );

      _logger.i(
        '예약 이동 완료\nid: ${reservation.id}, '
        '$fromStoreId → ${reservation.storeSummary.id}',
      );
      return right(null);
    } catch (e) {
      _logger.e('예약 이동 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> deleteReservation({
    required String storeId,
    required String reservationId,
  }) async {
    try {
      await _reservationDataSource.deleteReservation(storeId, reservationId);
      _logger.i('예약 삭제 완료\nid: $reservationId');
      return right(null);
    } catch (e) {
      _logger.e('예약 삭제 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> updateReservationStatus({
    required String storeId,
    required String reservationId,
    required ReservationStatus status,
  }) async {
    try {
      await _reservationDataSource.updateReservation(storeId, reservationId, {
        'status': status.jsonValue,
      });
      _logger.i('예약 상태 변경 완료\nid: $reservationId, status: ${status.jsonValue}');
      return right(null);
    } catch (e) {
      _logger.e('예약 상태 변경 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, int>> getReservationCountByCustomer({
    required String storeId,
    required String customerName,
    required String customerPhone,
  }) async {
    try {
      final count = await _reservationDataSource.getReservationCountByCustomer(
        storeId,
        customerName,
        customerPhone,
      );
      return right(count);
    } catch (e) {
      _logger.e('고객 예약 수 조회 실패');
      return left(toException(e));
    }
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// 단일 ReservationModel → Reservation 엔티티로 변환
  Future<Reservation> _buildReservationEntity({
    required ReservationModel model,
    required String storeId,
    required String currentUid,
  }) async {
    final currentUserModelFuture = _userDataSource.getUser(currentUid);
    final writerUserModelFuture = _getWriter(model.writerId);
    final currentUserModel = await currentUserModelFuture;
    final writerUserModel = await writerUserModelFuture;

    return model.toEntity(
      _buildStoreSummary(storeId: storeId, currentUserModel: currentUserModel),
      _buildWriter(
        writerUserModel: writerUserModel,
        writerRole: model.writerRole,
      ),
    );
  }

  /// StoreSummary 구성
  /// - 현재 사용자의 storeById에서 name/color 조회, 없으면 폴백
  StoreSummary _buildStoreSummary({
    required String storeId,
    required UserModel? currentUserModel,
  }) {
    final userStoreInfo = currentUserModel?.storeById[storeId];
    return StoreSummary(
      id: storeId,
      name: userStoreInfo?.name ?? '',
      alias: userStoreInfo?.alias,
      color: userStoreInfo?.color ?? StoreColor.red,
    );
  }

  /// 예약 작성자. 계정을 삭제한 작성자도 예약은 남으므로 삭제된 계정으로 채운다 (ADR-0005)
  /// - 문서 자체가 없어도 실패하거나 예약을 건너뛰지 않는다
  Future<UserModel> _getWriter(String uid) async {
    return await _userDataSource.getUserIncludingDeleted(uid) ??
        UserModel.deleted(id: uid);
  }

  /// [models]의 고유 작성자를 병렬로 조회한다. 모든 writerId가 키로 들어 있다
  Future<Map<String, UserModel>> _getWritersById(
    List<ReservationModel> models,
  ) async {
    final writerIds = models.map((m) => m.writerId).toSet().toList();
    final writers = await Future.wait(writerIds.map(_getWriter));
    return {
      for (var i = 0; i < writerIds.length; i++) writerIds[i]: writers[i],
    };
  }

  /// StoreMemberInfo(writer) 구성
  StoreMemberInfo _buildWriter({
    required UserModel writerUserModel,
    required UserRole writerRole,
  }) {
    return StoreMemberInfo(user: writerUserModel.toEntity(), role: writerRole);
  }
}

@Riverpod(keepAlive: true)
ReservationRepository reservationRepository(Ref ref) {
  final reservationDataSource = ref.watch(reservationDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);

  return ReservationRepositoryImpl(
    reservationDataSource: reservationDataSource,
    userDataSource: userDataSource,
  );
}
