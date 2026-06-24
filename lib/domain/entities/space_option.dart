import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';

part 'space_option.freezed.dart';

@freezed
abstract class SpaceOption with _$SpaceOption {
  const factory SpaceOption({
    required String id,
    required String name,
    required PriceSetting priceSetting,
  }) = _SpaceOption;

  factory SpaceOption.empty() => SpaceOption(
    id: const Uuid().v4(),
    name: '',
    priceSetting: PriceSetting.empty(),
  );
}
