import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';

part 'price_setting.freezed.dart';
part 'price_setting.g.dart';

@freezed
abstract class PriceSetting with _$PriceSetting {
  const factory PriceSetting({
    required List<DayGroup> dayGroups,
  }) = _PriceSetting;

  factory PriceSetting.fromJson(Map<String, dynamic> json) =>
      _$PriceSettingFromJson(json);
}
