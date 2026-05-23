import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/space_option.dart';
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
    @Default([]) List<SpaceOption> spaceOptions,
    @Default('') String bankName,
    @Default('') String bankAccountNumber,
    @Default('') String bankAccountHolder,
    int? paymentDeadlineMinutes,
    @Default('') String infoNotes,
    @Default('') String cautionNotes,

    @Default(AsyncData(null)) AsyncValue<void> status,
  }) = _StoreFormState;

  // TODO: 유효성 검사 확인 필요
  /// 필수 입력값만 체크
  bool get isValid => name.isNotEmpty && address.isNotEmpty;
}
