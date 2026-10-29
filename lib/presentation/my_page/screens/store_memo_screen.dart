import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_caption.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/my_store_settings_controller.dart';

/// 점포 메모 입력 — '완료'를 눌러야 저장한다 (색상과 달리 입력 중 저장 시점이 애매해서)
class StoreMemoScreen extends ConsumerStatefulWidget {
  const StoreMemoScreen({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<StoreMemoScreen> createState() => _StoreMemoScreenState();
}

class _StoreMemoScreenState extends ConsumerState<StoreMemoScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final memo = ref
        .read(currentUserProvider)
        .value
        ?.storeInfoOf(widget.storeId)
        ?.memo;
    _controller = TextEditingController(text: memo ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final succeeded = await ref
        .read(myStoreSettingsControllerProvider.notifier)
        .updateMemo(storeId: widget.storeId, memo: _controller.text);
    if (succeeded && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      myStoreSettingsControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      backgroundColor: context.systemGroupedBackground,
      appBar: CustomAppBar(
        title: '점포 메모',
        actions: [
          AppBarActionButton(label: '완료', onPressed: isSaving ? null : _save),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeAreaWithPadding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: GroupedFormContainer(
            footer: const GroupedFormCaption.footer(
              '점포 메모는 다른 멤버의 화면에 보이지 않습니다.',
            ),
            children: [
              MemoTextField(
                placeholder: '메모',
                controller: _controller,
                autofocus: true,
                maxLength: maxMemoCharCount,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxMemoCharCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
