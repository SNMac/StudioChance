import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form_selection_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class StoreColorSelectionScreen extends ConsumerWidget {
  const StoreColorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeToEdit = GoRouterState.of(context).extra as Store?;

    StoreFormState state;
    StoreFormControllerable notifier;

    if (storeToEdit != null) {
      state = ref.watch(storeUpdateControllerProvider(storeToEdit));
      notifier = ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      state = ref.watch(storeCreationControllerProvider);
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    return Scaffold(
      appBar: CustomAppBar(title: '색상 선택'),
      body: SafeAreaWithPadding(
        child: GroupedFormContainer(
          children: StoreColor.values.map((color) {
            return InputFormSelectionButton<StoreColor>(
              value: color,
              label: color.displayName,
              isSelected: state.color == color,
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(color.foregroundColorValue),
                  shape: BoxShape.circle,
                ),
              ),
              onPressed: () {
                notifier.setColor(color);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}