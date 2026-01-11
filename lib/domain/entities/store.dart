import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

part 'store.freezed.dart';

@freezed
abstract class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String address,
    required String memo,
    required StoreColor color,
    required List<User> members,
    required List<User> waitingMembers,
    required PriceSetting priceSettings,
    required InviteInfo? inviteInfo,

    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _Store;
}
