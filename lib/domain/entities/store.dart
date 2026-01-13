import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';

part 'store.freezed.dart';

@freezed
abstract class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String address,
    required String addressGuide,
    required String memo,
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
    required PriceSetting priceSettings,
    required InviteInfo? inviteInfo,

    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _Store;
}
