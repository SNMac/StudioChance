import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_store_preview.freezed.dart';

/// 초대 코드로 조회한 "가입 전 점포 표시 정보"
///
/// 아직 멤버가 아닌 사용자에게 보여줄 최소 정보만 담는다. 계좌 정보·멤버 목록·
/// 초대 코드는 Callable 함수(`lookupInviteCode`)가 애초에 내려주지 않는다.
@freezed
abstract class InviteStorePreview with _$InviteStorePreview {
  const factory InviteStorePreview({
    required String storeId,
    required String storeName,
    required String address,
    required String addressDetail,
    required String adminName,
  }) = _InviteStorePreview;
}
