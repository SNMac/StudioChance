import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

part 'store_input_form_state.freezed.dart';

@freezed
abstract class StoreInputFormState with _$StoreInputFormState {
  const StoreInputFormState._();

  const factory StoreInputFormState({
    @Default('') String name,
    @Default('') String address,
    @Default('') String memo,
    @Default(StoreColor.red) StoreColor color, // 기본 색상
    // 복잡한 객체는 nullable로 두거나, 기본값을 상수로 정의해서 넣어줌
    required PriceSetting priceSettings,
  }) = _StoreInputFormState;

  // TODO: 유효성 검사 확인 필요
  /// 필수 입력값만 체크 (가격 설정은 기본값이 있으므로 보통 체크 안 함)
  bool get isValid => name.isNotEmpty && address.isNotEmpty;
}
