import 'package:freezed_annotation/freezed_annotation.dart';

part 'headcount_rule_model.freezed.dart';
part 'headcount_rule_model.g.dart';

@freezed
abstract class HeadcountRuleModel with _$HeadcountRuleModel {
  const factory HeadcountRuleModel({
    required int headcountBase,
    required int headcountExtraPrice,
    required bool isHeadcountHourly,
    required bool isHeadcountPerPerson,
  }) = _HeadcountRuleModel;

  factory HeadcountRuleModel.fromJson(Map<String, dynamic> json) =>
      _$HeadcountRuleModelFromJson(json);
}
