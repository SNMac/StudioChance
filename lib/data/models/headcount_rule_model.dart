import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/headcount_rule.dart';

part 'headcount_rule_model.freezed.dart';
part 'headcount_rule_model.g.dart';

@freezed
abstract class HeadcountRuleModel with _$HeadcountRuleModel {
  const HeadcountRuleModel._();

  const factory HeadcountRuleModel({
    required int headcountBase,
    required int headcountExtraPrice,
    required bool isHeadcountHourly,
    required bool isHeadcountPerPerson,
  }) = _HeadcountRuleModel;

  factory HeadcountRuleModel.fromJson(Map<String, dynamic> json) =>
      _$HeadcountRuleModelFromJson(json);

  factory HeadcountRuleModel.fromEntity(HeadcountRule entity) {
    return HeadcountRuleModel(
      headcountBase: entity.headcountBase,
      headcountExtraPrice: entity.headcountExtraPrice,
      isHeadcountHourly: entity.isHeadcountHourly,
      isHeadcountPerPerson: entity.isHeadcountPerPerson,
    );
  }

  HeadcountRule toEntity() {
    return HeadcountRule(
      headcountBase: headcountBase,
      headcountExtraPrice: headcountExtraPrice,
      isHeadcountHourly: isHeadcountHourly,
      isHeadcountPerPerson: isHeadcountPerPerson,
    );
  }
}
