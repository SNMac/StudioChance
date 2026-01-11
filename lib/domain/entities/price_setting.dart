import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';

part 'price_setting.freezed.dart';

@freezed
abstract class PriceSetting with _$PriceSetting {
  const factory PriceSetting({
    required List<DayGroup> dayGroups,
  }) = _PriceSetting;
}
