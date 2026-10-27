import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/invite_store_preview.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_membership.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';

part 'store_repository_impl.g.dart';

class StoreRepositoryImpl implements StoreRepository {
  final Logger _logger = Logger();

  final StoreDataSource _storeDataSource;
  final UserDataSource _userDataSource;

  StoreRepositoryImpl({
    required this._storeDataSource,
    required this._userDataSource,
  });

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
        _toStoreEntity(
          createdModel,
          memberInfos: store.memberInfos,
          waitingMemberInfos: store.waitingMemberInfos,
        ),
      );
    } catch (e) {
      _logger.e('createStore 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, Store?>> getStore(String storeId) async {
    try {
      final storeModel = await _storeDataSource.getStore(storeId);

      if (storeModel == null) {
        return right(null);
      }

      final memberInfosFuture = _fetchMembersWithRoles(storeModel.memberById);
      final waitingInfosFuture = _fetchMembersWithRoles(
        storeModel.waitingMemberById,
      );
      final memberInfos = await memberInfosFuture;
      final waitingInfos = await waitingInfosFuture;

      return right(
        _toStoreEntity(
          storeModel,
          memberInfos: memberInfos,
          waitingMemberInfos: waitingInfos,
        ),
      );
    } catch (e) {
      _logger.e('getStore 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, StoreMembership?>> getMembership(
    String storeId,
  ) async {
    try {
      final storeModel = await _storeDataSource.getStore(storeId);
      if (storeModel == null) return right(null);

      return right(
        StoreMembership(
          roleByUid: storeModel.memberById.map(
            (uid, info) => MapEntry(uid, info.role),
          ),
        ),
      );
    } catch (e) {
      _logger.e('getMembership 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> updateStore({
    required Store original,
    required Store store,
    required String uid,
    required StoreColor color,
    required String memo,
  }) async {
    try {
      final originalJson = _comparableEditableJson(
        StoreModel.fromEntity(original),
      );
      await _storeDataSource.updateStore(
        store.id,
        StoreModel.fromEntity(store).toEditableJson(),
        isUnchanged: (current) => const DeepCollectionEquality().equals(
          _comparableEditableJson(current),
          originalJson,
        ),
      );

      // color.name은 Dart 식별자('green')를 반환하므로 toJson()으로 JSON 값('GREEN') 직렬화
      final colorJson =
          UserStoreInfoModel(
                name: '',
                role: UserRole.none,
                color: color,
                memo: '',
              ).toJson()['color']
              as String;
      await _userDataSource.updateStoreInfo(uid, store.id, {
        'color': colorJson,
        'memo': memo,
      });

      return right(null);
    } catch (e) {
      _logger.e('점포 업데이트 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> softDeleteStore(
    String storeId, {
    bool expireImmediately = false,
  }) async {
    try {
      final storeModel = await _storeDataSource.getStore(storeId);
      if (storeModel == null) return right(null);

      final memberUids = {
        ...storeModel.memberById.keys,
        ...storeModel.waitingMemberById.keys,
      }.toList();

      await _storeDataSource.softDeleteStore(
        storeId,
        memberUids,
        expireImmediately: expireImmediately,
      );
      _logger.i('점포 삭제 완료\nid: $storeId');
      return right(null);
    } catch (e) {
      _logger.e('점포 삭제 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  }) async {
    try {
      // 유효한 코드 재사용 판정은 서버가 서버 시각으로 한다 (ADR-0006)
      final inviteModel = await _storeDataSource.createInviteCode(
        storeId,
        forceRegenerate: forceRegenerate,
      );
      _logger.i('초대 코드 발급 완료\nstoreId: $storeId');
      return right(inviteModel.toEntity());
    } catch (e) {
      _logger.e('초대 코드 발급 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, Duration>> getServerClockOffset() async {
    try {
      final sentAt = DateTime.now();
      final serverNow = await _storeDataSource.getServerTime();
      final receivedAt = DateTime.now();
      // 서버가 응답을 만든 시각을 왕복의 한가운데로 본다
      final midpoint = sentAt.add(receivedAt.difference(sentAt) ~/ 2);
      return right(serverNow.difference(midpoint));
    } catch (e) {
      _logger.w('서버 시각 조회 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  ) async {
    try {
      // 만료 판정과 대표 관리자 조합은 Callable이 수행한다
      // (functions/src/invite/lookup_invite_code.ts).
      final model = await _storeDataSource.lookupInviteCode(inviteCode);
      if (model == null) return right(null);

      return right(model.toEntity());
    } catch (e) {
      _logger.e('초대 코드로 점포 조회 실패');
      return left(toException(e));
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
        isPending: true,
      );

      await _storeDataSource.requestJoinWithBatch(
        storeId,
        uid,
        memberInfo,
        userStoreInfo,
      );

      _logger.i('점포 가입 신청 완료 (대기열 추가)\nstoreId: $storeId, uid: $uid');
      // 관리자 FCM 알림은 Cloud Functions `notifyAdminsOnJoinRequest`가
      // stores/{storeId}.waitingMemberById 변경을 감지해 발송한다 (functions/src/index.ts).

      return right(null);
    } catch (e) {
      _logger.e('점포 가입 신청 실패');
      return left(toException(e));
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
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> delegateAdmin({
    required String storeId,
    required String fromUid,
    required String toUid,
    required UserRole previousAdminRole,
  }) async {
    try {
      await _storeDataSource.delegateAdmin(
        storeId,
        fromUid: fromUid,
        toUid: toUid,
        previousRole: previousAdminRole.jsonValue,
      );

      _logger.i('관리자 위임 완료\nstoreId: $storeId, from: $fromUid, to: $toUid');
      return right(null);
    } catch (e) {
      _logger.e('관리자 위임 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String uid,
  }) async {
    try {
      await _storeDataSource.removeMember(storeId, uid);

      _logger.i('멤버 제거 완료\nstoreId: $storeId, uid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('멤버 제거 실패');
      return left(toException(e));
    }
  }

  @override
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String uid,
    required UserRole newRole,
  }) async {
    try {
      await _storeDataSource.updateMemberRole(storeId, uid, newRole.jsonValue);

      _logger.i(
        '멤버 권한 변경 완료\nstoreId: $storeId, uid: $uid, role: ${newRole.name}',
      );
      return right(null);
    } catch (e) {
      _logger.e('멤버 권한 변경 실패');
      return left(toException(e));
    }
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// StoreModel → Store 변환 + legacy fallback 적용
  /// - spaceOptions가 비어있는 구버전 점포 문서는 기본 공간 1건으로 채워 반환한다.
  ///   (이 판단은 Data Model이 아닌 Repository의 책임이다)
  Store _toStoreEntity(
    StoreModel model, {
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
  }) {
    final store = model.toEntity(
      memberInfos: memberInfos,
      waitingMemberInfos: waitingMemberInfos,
    );
    if (store.spaceOptions.isNotEmpty) return store;

    return store.copyWith(
      spaceOptions: [
        SpaceOption(
          id: 'legacy_default',
          name: '기본 공간',
          priceSetting: PriceSetting.empty(),
        ),
      ],
    );
  }

  /// 동시 수정 비교(D13)용 편집 가능 필드.
  /// 폼의 점포는 legacy fallback을 거친 엔티티이므로 저장 직전 문서도 같은 fallback과
  /// 같은 엔티티 → 모델 변환을 거쳐야 한다. 그러지 않으면 spaceOptions가 빈 구버전 점포는
  /// 저장할 때마다 충돌로 판정된다.
  Map<String, dynamic> _comparableEditableJson(StoreModel model) =>
      StoreModel.fromEntity(
        _toStoreEntity(
          model,
          memberInfos: const [],
          waitingMemberInfos: const [],
        ),
      ).toEditableJson();

  /// 멤버 한 명의 사용자 문서. 문서가 깨져 읽지 못하면 그 멤버만 건너뛴다(null).
  ///
  /// 한 명의 문서 때문에 점포 조회 전체가 실패하면 공간·요금·승인 대기 화면이 모두 막힌다.
  /// 네트워크 오류는 모든 멤버에 똑같이 걸리므로 멤버가 조용히 사라져 보이지 않도록 그대로 던진다.
  Future<UserModel?> _getMemberUserOrSkip(String uid) async {
    try {
      return await _userDataSource.getUser(uid);
    } on UserNetworkException {
      rethrow;
    } catch (e) {
      _logger.e('멤버 사용자 문서를 읽지 못해 제외\nuid: $uid', error: e);
      return null;
    }
  }

  /// StoreMemberInfoModel Map을 받아 StoreMemberInfo Entity 목록으로 변환
  /// - input: `Map<UserID, StoreMemberInfoModel>`
  Future<List<StoreMemberInfo>> _fetchMembersWithRoles(
    Map<String, StoreMemberInfoModel> memberMap,
  ) async {
    if (memberMap.isEmpty) return [];

    final userIds = memberMap.keys.toList();

    final futures = userIds.map(_getMemberUserOrSkip);
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
