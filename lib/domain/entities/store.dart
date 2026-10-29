import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';

part 'store.freezed.dart';

@freezed
abstract class Store with _$Store {
  const Store._();

  const factory Store({
    required String id,
    required String name,
    required String address,
    required String addressDetail,
    required String addressGuide,
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
    required List<SpaceOption> spaceOptions,
    required InviteInfo? inviteInfo,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
    int? paymentDeadlineMinutes,
    String? infoNotes,
    String? cautionNotes,

    /// 점포 삭제로 삭제 예정 점포가 된 시각(서버 시각). 없으면 삭제 예정이 아니다 (ADR-0007)
    DateTime? deletedAt,
  }) = _Store;

  /// 삭제 예정 점포. 읽기 전용이며 관리자만 점포 복구·영구 삭제를 할 수 있다
  bool get isScheduledForDeletion => deletedAt != null;

  /// 완전히 지워지는 시각. 이 시각이 지나면 점포 복구를 할 수 없다
  DateTime? get deletionDeadline =>
      deletedAt?.add(const Duration(days: storeSoftDeleteDays));

  /// 멤버 목록 표시 순서: 관리자 → 스태프 → 뷰어, 같은 역할은 이름 가나다순
  List<StoreMemberInfo> get sortedMemberInfos => [...memberInfos]
    ..sort((a, b) {
      final byRole = a.role.index.compareTo(b.role.index);
      if (byRole != 0) return byRole;
      return a.user.displayName.compareTo(b.user.displayName);
    });

  /// spaceOptionId에 해당하는 PriceSetting 반환.
  /// null이거나 찾지 못하면 첫 번째 공간의 PriceSetting 반환.
  PriceSetting? priceSettingForSpace(String? spaceOptionId) {
    if (spaceOptions.isEmpty) return null;
    if (spaceOptionId != null) {
      final matched = spaceOptions
          .where((s) => s.id == spaceOptionId)
          .firstOrNull;
      if (matched != null) return matched.priceSetting;
    }
    return spaceOptions.first.priceSetting;
  }
}
