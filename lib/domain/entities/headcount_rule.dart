import 'package:freezed_annotation/freezed_annotation.dart';

part 'headcount_rule.freezed.dart';

@freezed
abstract class HeadcountRule with _$HeadcountRule {
  const factory HeadcountRule({
    required int headcountBase,
    required int headcountExtraPrice,
    required bool isHeadcountHourly,
    required bool isHeadcountPerPerson,
  }) = _HeadcountRule;
}
