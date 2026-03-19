import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_selection_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_switch_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class PriceDaysInputScreen extends ConsumerWidget {
  const PriceDaysInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final selectedDays = currentDayGroup.days;

    final Set<int> unavailableDays = {};
    for (int i = 0; i < state.priceSettings.dayGroups.length; i++) {
      if (i == groupIndex) continue;
      unavailableDays.addAll(state.priceSettings.dayGroups[i].days);
    }

    final List<({int value, String title})> weekDays = [
      (value: 7, title: '일요일'),
      (value: 1, title: '월요일'),
      (value: 2, title: '화요일'),
      (value: 3, title: '수요일'),
      (value: 4, title: '목요일'),
      (value: 5, title: '금요일'),
      (value: 6, title: '토요일'),
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: '기준 요일'),
      body: SafeAreaWithPadding(
        child: Column(
          spacing: 20,
          children: [
            GroupedFormContainer(
              children: weekDays.map((day) {
                final isSelected = selectedDays.contains(day.value);
                final isDisabled = unavailableDays.contains(day.value);

                return TitleSelectionButton<int>(
                  value: day.value,
                  title: day.title,
                  isSelected: isSelected,
                  onPressed: isDisabled
                      ? null
                      : () {
                          notifier.toggleDayGroupDay(groupIndex, day.value);
                        },
                );
              }).toList(),
            ),

            GroupedFormContainer(
              children: [
                Builder(
                  builder: (context) {
                    final isHolidayDisabled = unavailableDays.contains(
                      holidayValue,
                    );
                    return TitleSwitchButton(
                      title: '공휴일',
                      value: selectedDays.contains(holidayValue),
                      onChanged: isHolidayDisabled
                          ? null
                          : (_) {
                              notifier.toggleDayGroupDay(
                                groupIndex,
                                holidayValue,
                              );
                            },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
