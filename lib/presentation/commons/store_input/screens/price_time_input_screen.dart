import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/day_group_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class PriceTimeInputScreen extends ConsumerStatefulWidget {
  const PriceTimeInputScreen({super.key});

  @override
  ConsumerState<PriceTimeInputScreen> createState() =>
      _PriceTimeInputScreenState();
}

class _PriceTimeInputScreenState extends ConsumerState<PriceTimeInputScreen> {
  late TextEditingController _baseCountController;
  late TextEditingController _extraPriceController;

  late bool _isHourly;
  late bool _isPerPerson;

  bool _isFormValid = false;
  bool _isInitialized = false;

  /// 유효성 검사 로직
  void _validateForm() {
    final isValid =
        _baseCountController.text.isNotEmpty &&
        _extraPriceController.text.isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String _getFooterDescription() {
    if (_isHourly && _isPerPerson) {
      return '초과 인원 수만큼 1시간마다 부과됩니다';
    } else if (_isHourly) {
      return '추가 인원 요금이 1시간마다 부과됩니다';
    } else if (_isPerPerson) {
      return '초과 인원 수만큼 한 번만 부과됩니다';
    } else {
      return '추가 인원 요금이 한 번만 부과됩니다';
    }
  }

  void _initializeData(DayGroup currentGroup) {
    if (_isInitialized) return;

    _baseCountController = TextEditingController(
      text: currentGroup.headcountRule.headcountBase == -1
          ? ''
          : currentGroup.headcountRule.headcountBase.toString(),
    );
    _extraPriceController = TextEditingController(
      text: currentGroup.headcountRule.headcountExtraPrice == -1
          ? ''
          : currentGroup.headcountRule.headcountExtraPrice.toString(),
    );

    _isHourly = currentGroup.headcountRule.isHeadcountHourly;
    _isPerPerson = currentGroup.headcountRule.isHeadcountPerPerson;

    _baseCountController.addListener(_validateForm);
    _extraPriceController.addListener(_validateForm);

    _validateForm();

    _isInitialized = true;
  }

  @override
  void dispose() {
    _baseCountController.dispose();
    _extraPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final args = GoRouterState.of(context).extra as Map<String, dynamic>;
    final Store? storeToEdit = args['store'] as Store?;
    final int groupIndex = args['index'] as int;

    StoreFormState state;
    StoreFormControllerable notifier;

    if (storeToEdit != null) {
      state = ref.watch(storeUpdateControllerProvider(storeToEdit));
      notifier = ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      state = ref.watch(storeCreationControllerProvider);
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    if (groupIndex >= state.priceSettings.dayGroups.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomAlertDialog(
          context: context,
          title: '에러가 발생했습니다',
          content: '데이터를 찾을 수 없습니다. (Index Error)',
          showCancel: false,
          onConfirmAfterPop: () => context.pop(),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final currentDayGroup = state.priceSettings.dayGroups[groupIndex];
    _initializeData(currentDayGroup);

    void onSave() {
      final int base = int.tryParse(_baseCountController.text) ?? -1;
      final int extra = int.tryParse(_extraPriceController.text) ?? -1;

      final newRule = HeadcountRule(
        headcountBase: base,
        headcountExtraPrice: extra,
        isHeadcountHourly: _isHourly,
        isHeadcountPerPerson: _isPerPerson,
      );

      final newDayGroup = currentDayGroup.copyWith(
        headcountRule: newRule,
        // timeSlots: currentDayGroup.timeSlots (명시하지 않아도 유지됨)
      );

      notifier.setDayGroup(groupIndex, newDayGroup);

      context.pop();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: currentDayGroup.formattedDays,
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: _isFormValid ? onSave : null,
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: Column(
          spacing: 20,
          children: [
            GroupedFormContainer(
              header: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: horizontalPadding,
                ),
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
                padding: const EdgeInsetsDirectional.only(
                  start: horizontalPadding,
                ),
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  placeholder: '예: 5000',
                ),
                TitleSwitchButton(
                  title: '추가 요금 시간당 부과',
                  value: _isHourly,
                  onChanged: (val) => setState(() => _isHourly = val),
                ),
                TitleSwitchButton(
                  title: '추가 요금 인원당 부과',
                  value: _isPerPerson,
                  onChanged: (val) => setState(() => _isPerPerson = val),
                ),
              ],
            ),

            GroupedFormContainer(children: [

            ])
          ],
        ),
      ),
    );
  }
}
