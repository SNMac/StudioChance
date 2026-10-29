import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';

part 'user.freezed.dart';

/// [User.memberStoreInfos]를 사용자 객체마다 한 번만 만들기 위한 캐시.
/// User는 불변이라 같은 객체의 결과는 바뀌지 않고, 객체가 사라지면 함께 사라진다.
final _memberStoreInfosCache = Expando<List<UserStoreInfo>>();

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String name,
    required String email,
    required String? nickname,
    required List<String> authProviders,
    required List<UserStoreInfo> storeInfos,

    /// 삭제된 계정. 닉네임만 남아 있으며 화면에서는 "닉네임 (삭제된 계정)"으로 구분한다
    @Default(false) bool isDeleted,
  }) = _User;

  bool get isNewUser => nickname == null;

  /// 다른 사람에게 보이는 이름. 닉네임이 없으면(가입 직후) 소셜 계정 이름을 쓴다
  String get displayName => nickname ?? name;

  /// 승인된(멤버인) 점포만. 승인 대기 점포는 Rules가 점포·예약 읽기를 거부하므로
  /// 예약 조회·필터·예약 생성처럼 점포 데이터를 읽는 곳은 이 목록을 쓴다.
  ///
  /// 같은 사용자 객체에서는 같은 목록 인스턴스를 돌려준다. 매번 새 리스트를 만들면
  /// `select`가 사용자 정보를 다시 불러오는 동안(로딩 상태)에도 값이 바뀐 것으로 보고
  /// 화면을 다시 그린다 (storeInfos도 같은 객체면 같은 리스트다).
  List<UserStoreInfo> get memberStoreInfos => _memberStoreInfosCache[this] ??=
      List.unmodifiable(storeInfos.where((info) => !info.isPending));

  /// 기한이 지난 삭제 예정 점포를 뺀 사용자. TTL이 점포를 지우고 `cascadeStoreDelete`가
  /// 항목을 지울 때까지(최대 이틀) 남아 있는 점포를 목록에서 감춘다 (ADR-0007)
  /// - [now]는 서버 시각으로 보정한 시각이어야 한다. 기한은 서버 시각 기준이다
  User withoutExpiredStores(DateTime now) => copyWith(
    storeInfos: storeInfos
        .where((info) => !info.isDeletionDeadlinePassedAt(now))
        .toList(),
  );

  /// [storeId] 점포에서의 내 정보(표시 이름·역할·색상·메모). 소속되지 않았으면 null
  UserStoreInfo? storeInfoOf(String storeId) =>
      storeInfos.where((info) => info.id == storeId).firstOrNull;

  /// [storeId] 점포에서의 내 역할. 소속되지 않았거나 승인 대기 중이면 null
  ///
  /// 승인 대기 점포의 role은 신청한 역할일 뿐 권한이 아니다.
  UserRole? roleIn(String storeId) {
    final info = storeInfoOf(storeId);
    return info == null || info.isPending ? null : info.role;
  }
}
