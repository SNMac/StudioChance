import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/price_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';

class HeadcountInputForm extends StatefulWidget {
  final HeadcountRule initialRule;

  /// 데이터가 변경될 때마다 호출됨 (변경된 룰, 유효성 여부)
  final void Function(HeadcountRule rule, bool isValid) onChanged;

  const HeadcountInputForm({
    super.key,
    required this.initialRule,
    required this.onChanged,
  });

  @override
  State<HeadcountInputForm> createState() => _HeadcountInputFormState();
}

class _HeadcountInputFormState extends State<HeadcountInputForm> {
  late final TextEditingController _baseCountController;
  late final TextEditingController _extraPriceController;
  late final FocusNode _extraPriceFocusNode;

  late bool _isHourly;
  late bool _isPerPerson;

  @override
  void initState() {
    super.initState();
    _baseCountController = TextEditingController(
      text: widget.initialRule.headcountBase == -1
          ? ''
          : widget.initialRule.headcountBase.toString(),
    );
    _extraPriceFocusNode = FocusNode();
    _extraPriceController = TextEditingController(
      text: widget.initialRule.headcountExtraPrice == -1
          ? ''
          : widget.initialRule.headcountExtraPrice.formattedPrice,
    );
    _isHourly = widget.initialRule.isHeadcountHourly;
    _isPerPerson = widget.initialRule.isHeadcountPerPerson;

    _baseCountController.addListener(_notifyParent);
    _extraPriceController.addListener(_notifyParent);
    _extraPriceFocusNode.addListener(_onExtraFocusChanged);
  }

  @override
  void dispose() {
    _extraPriceFocusNode.dispose();
    _baseCountController.dispose();
    _extraPriceController.dispose();
    super.dispose();
  }

  void _onExtraFocusChanged() {
    final raw = _extraPriceController.text.replaceAll(',', '').replaceAll('원', '');
    if (_extraPriceFocusNode.hasFocus) {
      _extraPriceController.value = TextEditingValue(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      );
    } else {
      final price = int.tryParse(raw);
      if (price != null && price >= 0) {
        final formatted = price.formattedPrice;
        _extraPriceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  /// 상태 변경 시 부모 위젯에 데이터 전달
  void _notifyParent() {
    final baseText = _baseCountController.text;
    final extraText = _extraPriceController.text.replaceAll(',', '').replaceAll('원', '');

    final isValid = baseText.isNotEmpty && extraText.isNotEmpty;

    final newRule = widget.initialRule.copyWith(
      headcountBase: int.tryParse(baseText) ?? -1,
      headcountExtraPrice: int.tryParse(extraText) ?? -1,
      isHeadcountHourly: _isHourly,
      isHeadcountPerPerson: _isPerPerson,
    );

    widget.onChanged(newRule, isValid);

    setState(() {});
  }

  String _getFooterDescription() {
    if (_isHourly && _isPerPerson) {
      return '초과 인원수만큼 추가 요금이 1시간마다 부과됩니다';
    } else if (_isHourly) {
      return '추가 요금이 1시간마다 부과됩니다';
    } else if (_isPerPerson) {
      return '초과 인원수만큼 추가 요금이 한 번만 부과됩니다';
    } else {
      return '초과 인원수와 관계없이 추가 요금이 한 번만 부과됩니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GroupedFormContainer(
      header: Padding(
        padding: const EdgeInsetsDirectional.only(start: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인원별 요금 설정',
              style: textTheme.labelMedium?.copyWith(
                color: context.secondaryLabel,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),

      footer: Padding(
        padding: const EdgeInsetsDirectional.only(start: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getFooterDescription(),
              style: textTheme.labelMedium?.copyWith(
                color: context.secondaryLabel,
              ),
            ),
          ],
        ),
      ),

      children: [
        TitleTextField(
          title: '기준 인원',
          controller: _baseCountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          placeholder: '예: 4',
        ),
        TitleTextField(
          title: '추가 인원 요금',
          controller: _extraPriceController,
          focusNode: _extraPriceFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          placeholder: '예: 2,000',
        ),
        TitleSwitchButton(
          title: '추가 요금 시간당 부과',
          value: _isHourly,
          onChanged: (val) {
            _isHourly = val;
            _notifyParent();
          },
        ),
        TitleSwitchButton(
          title: '추가 요금 인원당 부과',
          value: _isPerPerson,
          onChanged: (val) {
            _isPerPerson = val;
            _notifyParent();
          },
        ),
      ],
    );
  }
}
