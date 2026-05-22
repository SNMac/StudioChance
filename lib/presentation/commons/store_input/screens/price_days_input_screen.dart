import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/weekday.dart';
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

    final PriceSetting priceSettings;
    final StoreFormControllerable notifier;

    if (storeToEdit != null) {
      priceSettings = ref.watch(
        storeUpdateControllerProvider(storeToEdit).select((s) => s.priceSettings),
      );
      notifier = ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      priceSettings = ref.watch(
        storeCreationControllerProvider.select((s) => s.priceSettings),
      );
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    if (groupIndex >= priceSettings.dayGroups.length) {
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

    final currentDayGroup = priceSettings.dayGroups[groupIndex];
    final selectedDays = currentDayGroup.days;

    final Set<Weekday> unavailableDays = {};
    for (int i = 0; i < priceSettings.dayGroups.length; i++) {
      if (i == groupIndex) continue;
      unavailableDays.addAll(priceSettings.dayGroups[i].days);
    }

    const List<Weekday> weekDays = [
      Weekday.sunday,
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
      Weekday.saturday,
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: '기준 요일'),
      body: SafeAreaWithPadding(
        child: Column(
          spacing: 20,
          children: [
            GroupedFormContainer(
              children: weekDays.map((day) {
                final isSelected = selectedDays.contains(day);
                final isDisabled = unavailableDays.contains(day);

                return TitleSelectionButton<Weekday>(
                  value: day,
                  title: day.displayName,
                  isSelected: isSelected,
                  onPressed: isDisabled
                      ? null
                      : () {
                          notifier.toggleDayGroupDay(groupIndex, day);
                        },
                );
              }).toList(),
            ),

            GroupedFormContainer(
              children: [
                Builder(
                  builder: (context) {
                    final isHolidayDisabled = unavailableDays.contains(
                      Weekday.holiday,
                    );
                    return TitleSwitchButton(
                      title: '공휴일',
                      value: selectedDays.contains(Weekday.holiday),
                      onChanged: isHolidayDisabled
                          ? null
                          : (_) {
                              notifier.toggleDayGroupDay(
                                groupIndex,
                                Weekday.holiday,
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
