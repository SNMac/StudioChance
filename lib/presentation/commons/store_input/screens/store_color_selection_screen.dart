import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_selection_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class StoreColorSelectionScreen extends ConsumerWidget {
  /// 점포 폼 컨트롤러가 아닌 다른 상태에 색상을 연결할 때 사용 (예: 가입 신청 화면).
  /// 둘 다 생략하면 점포 생성/수정 컨트롤러를 사용한다.
  final StoreColor? selected;
  final ValueChanged<StoreColor>? onSelected;

  const StoreColorSelectionScreen({super.key, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StoreColor selectedColor;
    ValueChanged<StoreColor> onColorSelected;

    if (onSelected != null) {
      selectedColor = selected ?? StoreColor.red;
      onColorSelected = onSelected!;
    } else {
      final storeToEdit = GoRouterState.of(context).extra as Store?;

      StoreFormState state;
      StoreFormControllerable notifier;

      if (storeToEdit != null) {
        state = ref.watch(storeUpdateControllerProvider(storeToEdit));
        notifier = ref.read(
          storeUpdateControllerProvider(storeToEdit).notifier,
        );
      } else {
        state = ref.watch(storeCreationControllerProvider);
        notifier = ref.read(storeCreationControllerProvider.notifier);
      }

      selectedColor = state.color;
      onColorSelected = notifier.setColor;
    }

    return Scaffold(
      appBar: const CustomAppBar(title: '색상 선택'),
      body: SafeAreaWithPadding(
        child: GroupedFormContainer(
          children: StoreColor.values.map((color) {
            return TitleSelectionButton<StoreColor>(
              value: color,
              title: color.displayName,
              isSelected: selectedColor == color,
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(color.foregroundColorValue),
                  shape: BoxShape.circle,
                ),
              ),
              onPressed: () {
                onColorSelected(color);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
