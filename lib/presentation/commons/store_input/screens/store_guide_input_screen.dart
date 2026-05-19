import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/router/router_path.dart';

class StoreGuideInputScreen extends ConsumerStatefulWidget {
  const StoreGuideInputScreen({super.key});

  @override
  ConsumerState<StoreGuideInputScreen> createState() =>
      _StoreGuideInputScreenState();
}

class _StoreGuideInputScreenState
    extends ConsumerState<StoreGuideInputScreen> {
  late final TextEditingController _notesController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final storeToEdit = GoRouterState.of(context).extra as Store?;

      StoreFormState formState;
      if (storeToEdit != null) {
        formState = ref.read(storeUpdateControllerProvider(storeToEdit));
      } else {
        formState = ref.read(storeCreationControllerProvider);
      }

      _notesController.text = formState.confirmationNotes;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save(StoreFormControllerable notifier) {
    notifier.setConfirmationNotes(_notesController.text);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final storeToEdit = GoRouterState.of(context).extra as Store?;

    final StoreFormControllerable notifier;
    if (storeToEdit != null) {
      notifier =
          ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '안내사항',
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: () => _save(notifier),
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: Column(
          spacing: 20,
          children: [
            GroupedFormContainer(
              children: [
                MemoTextField(
                  placeholder: '점포 안내·주의사항',
                  controller: _notesController,
                  maxLength: maxConfirmationNotesCharCount,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      maxConfirmationNotesCharCount,
                    ),
                  ],
                ),
              ],
            ),
            GroupedFormContainer(
              children: [
                TextActionButton(
                  title: '확정 안내문',
                  onPressed: () {
                    notifier.setConfirmationNotes(_notesController.text);
                    SCRoute.confirmationNotice.pushChild(
                      context,
                      extra: storeToEdit,
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
