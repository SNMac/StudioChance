import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/day_group_model.dart';

part 'price_settings_model.freezed.dart';
part 'price_settings_model.g.dart';

@freezed
abstract class PriceSettingsModel with _$PriceSettingsModel {
  const factory PriceSettingsModel({
    @Default([]) List<DayGroupModel> dayGroups,
  }) = _PriceSettingsModel;

  factory PriceSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$PriceSettingsModelFromJson(json);
}
