import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/reservation_exceptions.dart';
import 'package:studio_chance/data/data_sources/reservation_data_source.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';

part 'reservation_repository_impl.g.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final Logger _logger = Logger();

  final ReservationDataSource _reservationDataSource;
  final StoreDataSource _storeDataSource;
  final UserDataSource _userDataSource;

  ReservationRepositoryImpl({
    required ReservationDataSource reservationDataSource,
    required StoreDataSource storeDataSource,
    required UserDataSource userDataSource,
  }) : _reservationDataSource = reservationDataSource,
       _storeDataSource = storeDataSource,
       _userDataSource = userDataSource;

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
      return left(e is Exception ? e : Exception(e.toString()));
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
      return left(e is Exception ? e : Exception(e.toString()));
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

      // 점포 정보와 현재 사용자 정보를 병렬로 조회
      final storeModelFuture = _storeDataSource.getStore(storeId);
      final currentUserModelFuture = _userDataSource.getUser(currentUid);
      final storeModel = await storeModelFuture;
      final currentUserModel = await currentUserModelFuture;

      if (storeModel == null) {
        throw ReservationNotFoundException(message: '점포를 찾을 수 없습니다.');
      }

      final storeSummary = _buildStoreSummary(
        storeModel: storeModel,
        storeId: storeId,
        currentUserModel: currentUserModel,
      );

      // 고유 작성자 ID 목록 수집 후 병렬 조회
      final writerIds = models.map((m) => m.writerId).toSet().toList();
      final writerModels = await Future.wait(
        writerIds.map((uid) => _userDataSource.getUser(uid)),
      );

      final writerById = {
        for (var i = 0; i < writerIds.length; i++)
          if (writerModels[i] != null)
            writerIds[i]: writerModels[i]!,
      };

      final reservations = models.map((model) {
        final writerUserModel = writerById[model.writerId];
        if (writerUserModel == null) {
          throw ReservationNotFoundException(
            message: '작성자 정보를 찾을 수 없습니다. writerId: ${model.writerId}',
          );
        }

        return model.toEntity(
          storeSummary,
          _buildWriter(writerUserModel: writerUserModel, storeModel: storeModel),
        );
      }).toList();

      return right(reservations);
    } catch (e) {
      _logger.e('예약 목록 조회 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
  }) async {
    try {
      final model = ReservationModel.fromEntity(reservation);
      final json = model.toJson();

      await _reservationDataSource.updateReservation(
        reservation.storeSummary.id,
        reservation.id,
        json,
      );

      _logger.i('예약 수정 완료\nid: ${reservation.id}');
      return right(null);
    } catch (e) {
      _logger.e('예약 수정 실패');
      return left(e is Exception ? e : Exception(e.toString()));
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
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateReservationStatus({
    required String storeId,
    required String reservationId,
    required ReservationStatus status,
  }) async {
    try {
      await _reservationDataSource.updateReservation(
        storeId,
        reservationId,
        {'status': status.name},
      );
      _logger.i('예약 상태 변경 완료\nid: $reservationId, status: ${status.name}');
      return right(null);
    } catch (e) {
      _logger.e('예약 상태 변경 실패');
      return left(e is Exception ? e : Exception(e.toString()));
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
    final storeModelFuture = _storeDataSource.getStore(storeId);
    final currentUserModelFuture = _userDataSource.getUser(currentUid);
    final writerUserModelFuture = _userDataSource.getUser(model.writerId);
    final storeModel = await storeModelFuture;
    final currentUserModel = await currentUserModelFuture;
    final writerUserModel = await writerUserModelFuture;

    if (storeModel == null) {
      throw ReservationNotFoundException(message: '점포를 찾을 수 없습니다.');
    }
    if (writerUserModel == null) {
      throw ReservationNotFoundException(
        message: '작성자 정보를 찾을 수 없습니다.',
      );
    }

    return model.toEntity(
      _buildStoreSummary(
        storeModel: storeModel,
        storeId: storeId,
        currentUserModel: currentUserModel,
      ),
      _buildWriter(writerUserModel: writerUserModel, storeModel: storeModel),
    );
  }

  /// StoreSummary 구성
  /// - 현재 사용자의 해당 점포 색상 사용, 없으면 [StoreColor.red] 폴백
  StoreSummary _buildStoreSummary({
    required StoreModel storeModel,
    required String storeId,
    required UserModel? currentUserModel,
  }) {
    final color =
        currentUserModel?.storeById[storeId]?.color ?? StoreColor.red;
    return StoreSummary(id: storeId, name: storeModel.name, color: color);
  }

  /// StoreMemberInfo(writer) 구성
  StoreMemberInfo _buildWriter({
    required UserModel writerUserModel,
    required StoreModel storeModel,
  }) {
    final writerRole =
        storeModel.memberById[writerUserModel.id]?.role ??
        storeModel.waitingMemberById[writerUserModel.id]?.role;

    if (writerRole == null) {
      throw ReservationNotFoundException(
        message: '작성자의 역할 정보를 찾을 수 없습니다. writerId: ${writerUserModel.id}',
      );
    }

    return StoreMemberInfo(user: writerUserModel.toEntity(), role: writerRole);
  }
}

@Riverpod(keepAlive: true)
ReservationRepository reservationRepository(Ref ref) {
  final reservationDataSource = ref.watch(reservationDataSourceProvider);
  final storeDataSource = ref.watch(storeDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);

  return ReservationRepositoryImpl(
    reservationDataSource: reservationDataSource,
    storeDataSource: storeDataSource,
    userDataSource: userDataSource,
  );
}
