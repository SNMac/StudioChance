import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/day_group_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class PriceTimeInputScreen extends ConsumerWidget {
  const PriceTimeInputScreen({super.key});

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

    return Scaffold(
      appBar: CustomAppBar(title: currentDayGroup.formattedDays),
      body: SafeAreaWithPadding(),
    );
  }
}
