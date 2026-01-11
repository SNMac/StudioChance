import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';

import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';

part 'store_repository_impl.g.dart';

class StoreRepositoryImpl implements StoreRepository {
  final Logger _logger = Logger();

  final StoreDataSource _storeDataSource;
  final UserDataSource _userDataSource;

  StoreRepositoryImpl({
    required StoreDataSource storeDataSource,
    required UserDataSource userDataSource,
  }) : _storeDataSource = storeDataSource,
       _userDataSource = userDataSource;

  @override
  Future<Either<Exception, Store>> createStore(Store store) async {
    try {
      if (store.members.isEmpty) {
        return left(StoreValidationException(message: '초기 멤버 정보가 누락되었습니다.'));
      }

      final creatorId = store.members.first.id;

      final storeModel = StoreModel.fromEntity(store);

      final createdModel = await _storeDataSource.createStore(
        storeModel,
        creatorId,
      );

      return right(
        createdModel.toEntity(
          members: store.members,
          waitingMembers: store.waitingMembers,
        ),
      );
    } catch (e) {
      _logger.e('createStore 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Store?>> getStore(String storeId) async {
    try {
      final storeModel = await _storeDataSource.getStore(storeId);

      if (storeModel == null) {
        return right(null);
      }

      final results = await Future.wait([
        _fetchMembersWithRoles(storeModel.memberIds),
        _fetchMembersWithRoles(storeModel.waitingMemberIds),
      ]);

      return right(
        storeModel.toEntity(members: results[0], waitingMembers: results[1]),
      );
    } catch (e) {
      _logger.e('getStore 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateStore(
    String storeId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _storeDataSource.updateStore(storeId, data);
      _logger.i('점포 업데이트 완료\nid: $storeId\n$data');
      return right(null);
    } catch (e) {
      _logger.e('점포 업데이트 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> softDeleteStore(String storeId) async {
    try {
      await _storeDataSource.softDeleteStore(storeId);
      _logger.i('점포 삭제 완료\nid: $storeId');
      return right(null);
    } catch (e) {
      _logger.e('점포 삭제 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  }) async {
    try {
      final inviteModel = await _storeDataSource.createInviteCode(
        storeId,
        forceRegenerate: forceRegenerate,
      );
      _logger.i('초대코드 생성 완료\nstoreId: $storeId');
      return right(inviteModel.toEntity());
    } catch (e) {
      _logger.e('초대코드 생성 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Store?>> getStoreByInviteCode(
    String inviteCode,
  ) async {
    try {
      final storeModel = await _storeDataSource.getStoreByInviteCode(
        inviteCode,
      );

      if (storeModel == null) {
        return right(null);
      }

      final results = await Future.wait([
        _fetchMembersWithRoles(storeModel.memberIds),
        _fetchMembersWithRoles(storeModel.waitingMemberIds),
      ]);

      return right(
        storeModel.toEntity(members: results[0], waitingMembers: results[1]),
      );
    } catch (e) {
      _logger.e('초대코드로 점포 조회 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> requestJoinStore({
    required String storeId,
    required String uid,
    required UserRole role,
  }) async {
    try {
      await _storeDataSource.addWaitingMember(storeId, uid, role.name);

      _logger.i('점포 가입 신청 완료 (대기열 추가)\nstoreId: $storeId, uid: $uid');
      // TODO: 여기서 Admin에게 알림 발송 로직 추가 가능

      return right(null);
    } catch (e) {
      _logger.e('점포 가입 신청 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> approveMember({
    required String storeId,
    required String uid,
    required UserRole role,
  }) async {
    try {
      await _storeDataSource.approveMemberWithBatch(storeId, uid, role.name);
      _logger.i('멤버 승인 및 데이터 동기화 완료\nstoreId: $storeId, uid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('멤버 승인 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// memberIds Map을 받아 UserEntity 목록을 반환 (Role 주입 포함)
  /// - input: `Map<UserID, RoleString>`
  ///   - 예: `{'user1': 'admin', 'user2': 'staff'}`
  Future<List<User>> _fetchMembersWithRoles(
    Map<String, String> memberIdsMap,
  ) async {
    if (memberIdsMap.isEmpty) return [];

    final userIds = memberIdsMap.keys.toList();

    final futures = userIds.map((uid) => _userDataSource.getUser(uid));
    final userModels = await Future.wait(futures);

    return userModels.where((model) => model != null).map((model) {
      final userEntity = model!.toEntity(stores: []);

      final roleString = memberIdsMap[model.id];
      final role = UserRole.values.firstWhere(
        (e) => e.name == roleString,
        orElse: () => UserRole.none,
      );

      return userEntity.copyWith(role: role);
    }).toList();
  }
}

@Riverpod(keepAlive: true)
StoreRepository storeRepository(Ref ref) {
  final storeDataSource = ref.watch(storeDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);

  return StoreRepositoryImpl(
    storeDataSource: storeDataSource,
    userDataSource: userDataSource,
  );
}
