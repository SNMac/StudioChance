import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _Store;

  /// spaceOptionId에 해당하는 PriceSetting 반환.
  /// null이거나 찾지 못하면 첫 번째 공간의 PriceSetting 반환.
  PriceSetting? priceSettingForSpace(String? spaceOptionId) {
    if (spaceOptions.isEmpty) return null;
    if (spaceOptionId != null) {
      final matched = spaceOptions.where((s) => s.id == spaceOptionId).firstOrNull;
      if (matched != null) return matched.priceSetting;
    }
    return spaceOptions.first.priceSetting;
  }
}
