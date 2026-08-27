import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/constants/data_constants.dart';

part 'invite_info.freezed.dart';

@freezed
abstract class InviteInfo with _$InviteInfo {
  const InviteInfo._();

  const factory InviteInfo({
    required String inviteCode,

    /// 서버가 확정한 생성 시각. 발급 직후에도 채워진다
    /// (`StoreDataSource.createInviteCode`가 쓰기 후 다시 읽어 온다).
    DateTime? createdAt,
  }) = _InviteInfo;

  /// 만료 시각. [createdAt]을 모르면 null.
  ///
  /// 만료 판정의 기준은 서버 시각이다(`StoreRepositoryImpl`이 `getServerTime`으로
  /// 검증한다). 이 값을 로컬 시계와 비교하는 곳은 남은 시간 표시처럼 오차가
  /// 허용되는 경우로 한정할 것.
  DateTime? get expiresAt =>
      createdAt?.add(const Duration(minutes: storeInviteCodeAvailableMin));
}
