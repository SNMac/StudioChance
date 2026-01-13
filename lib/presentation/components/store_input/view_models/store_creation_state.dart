import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

part 'store_creation_state.freezed.dart';

@freezed
abstract class StoreCreationState with _$StoreCreationState {
  const StoreCreationState._();

  const factory StoreCreationState({
    @Default('') String name,
    @Default('') String address,
    @Default('') String memo,
    StoreColor? selectedColor,
    PriceSetting? priceSetting,
  }) = _StoreCreationState;

  bool get isValid =>
      name.isNotEmpty &&
      address.isNotEmpty &&
      selectedColor != null &&
      priceSetting != null;
}
