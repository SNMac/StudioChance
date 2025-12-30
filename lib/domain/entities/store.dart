import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/user.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
abstract class Store with _$Store {
  const factory Store({
    required String id,
    required String ownerId,
    required String name,
    required String color,
    required List<User> members,
    required List<DayGroup> priceSettings,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
