import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

part 'store_form_state.freezed.dart';

@freezed
abstract class StoreFormState with _$StoreFormState {
  const StoreFormState._();

  const factory StoreFormState({
    @Default('') String name,
    @Default('') String address,
    @Default('') String addressDetail,
    @Default('') String addressGuide,
    @Default('') String memo,
    @Default(StoreColor.red) StoreColor color,
    required PriceSetting priceSettings,

    @Default(AsyncValue.data(null)) AsyncValue<void> status,
  }) = _StoreFormState;

  // TODO: 유효성 검사 확인 필요
  /// 필수 입력값만 체크 (가격 설정은 기본값이 있으므로 보통 체크 안 함)
  bool get isValid => name.isNotEmpty && address.isNotEmpty;
}
