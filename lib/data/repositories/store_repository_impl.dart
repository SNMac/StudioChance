import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
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
  Future<Either<Exception, Store>> createStore({
    required Store store,
    required StoreColor color,
    required String memo,
  }) async {
    try {
      if (store.memberInfos.isEmpty) {
        return left(StoreValidationException(message: '관리자 정보가 누락되었습니다.'));
      }

      final creator = store.memberInfos.first;
      final creatorId = creator.user.id;

      final storeModel = StoreModel.fromEntity(store);

      final creatorInfo = UserStoreInfoModel(
        name: store.name,
        color: color,
        role: creator.role,
        memo: memo,
      );

      final createdModel = await _storeDataSource.createStore(
        storeModel,
        creatorId,
        creatorInfo,
      );

      return right(
        createdModel.toEntity(
          memberInfos: store.memberInfos,
          waitingMemberInfos: store.waitingMemberInfos,
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
        _fetchMembersWithRoles(storeModel.memberById),
        _fetchMembersWithRoles(storeModel.waitingMemberById),
      ]);

      return right(
        storeModel.toEntity(
          memberInfos: results[0],
          waitingMemberInfos: results[1],
        ),
      );
    } catch (e) {
      _logger.e('getStore 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateStore({
    required Store store,
    required String uid,
    required StoreColor color,
    required String memo,
  }) async {
    try {
      final storeModel = StoreModel.fromEntity(store);

      await _storeDataSource.updateStore(store.id, storeModel.toEditableJson());

      await _userDataSource.updateStoreInfo(uid, store.id, {
        'color': color.name,
        'memo': memo,
      });

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
      _logger.i('초대 코드 생성 완료\nstoreId: $storeId');
      return right(inviteModel.toEntity());
    } catch (e) {
      _logger.e('초대 코드 생성 실패');
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
        _fetchMembersWithRoles(storeModel.memberById),
        _fetchMembersWithRoles(storeModel.waitingMemberById),
      ]);

      return right(
        storeModel.toEntity(
          memberInfos: results[0],
          waitingMemberInfos: results[1],
        ),
      );
    } catch (e) {
      _logger.e('초대 코드로 점포 조회 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> requestJoinStore({
    required String storeId,
    required String uid,
    required UserRole role,
    required StoreColor color,
    required String storeAlias,
    required String memo,
  }) async {
    try {
      final memberInfo = StoreMemberInfoModel(role: role);

      final userStoreInfo = UserStoreInfoModel(
        name: storeAlias,
        color: color,
        role: role,
        memo: memo,
      );

      await _storeDataSource.requestJoinWithBatch(
        storeId,
        uid,
        memberInfo,
        userStoreInfo,
      );

      _logger.i('점포 가입 신청 완료 (대기열 추가)\nstoreId: $storeId, uid: $uid');
      // TODO: FCM 알림

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
      final memberInfo = StoreMemberInfoModel(role: role);

      await _storeDataSource.approveMember(storeId, uid, memberInfo);

      _logger.i('멤버 승인 완료\nstoreId: $storeId, uid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('멤버 승인 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String uid,
    required UserRole newRole,
  }) async {
    try {
      await _storeDataSource.updateMemberRole(storeId, uid, newRole.name);

      _logger.i(
        '멤버 권한 변경 완료\nstoreId: $storeId, uid: $uid, role: ${newRole.name}',
      );
      return right(null);
    } catch (e) {
      _logger.e('멤버 권한 변경 실패');
      return left(e is Exception ? e : Exception(e.toString()));
    }
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// StoreMemberInfoModel Map을 받아 StoreMemberInfo Entity 목록으로 변환
  /// - input: `Map<UserID, StoreMemberInfoModel>`
  Future<List<StoreMemberInfo>> _fetchMembersWithRoles(
    Map<String, StoreMemberInfoModel> memberMap,
  ) async {
    if (memberMap.isEmpty) return [];

    final userIds = memberMap.keys.toList();

    final futures = userIds.map((uid) => _userDataSource.getUser(uid));
    final userModels = await Future.wait(futures);

    return userModels.where((model) => model != null).map((userModel) {
      final userEntity = userModel!.toEntity();

      final infoModel = memberMap[userModel.id]!;

      return infoModel.toEntity(user: userEntity);
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
