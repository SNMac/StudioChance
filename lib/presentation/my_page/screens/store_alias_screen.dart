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
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/my_store_settings_controller.dart';

/// 점포 별명 입력 — '완료'를 눌러야 저장한다. 비워 두고 저장하면 점포 별명을 지운다
class StoreAliasScreen extends ConsumerStatefulWidget {
  const StoreAliasScreen({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<StoreAliasScreen> createState() => _StoreAliasScreenState();
}

class _StoreAliasScreenState extends ConsumerState<StoreAliasScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final alias = ref
        .read(currentUserProvider)
        .value
        ?.storeInfoOf(widget.storeId)
        ?.alias;
    _controller = TextEditingController(text: alias ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final succeeded = await ref
        .read(myStoreSettingsControllerProvider.notifier)
        .updateAlias(storeId: widget.storeId, alias: _controller.text);
    if (succeeded && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      myStoreSettingsControllerProvider.select((s) => s.isLoading),
    );
    final storeName = ref.watch(
      currentUserProvider.select(
        (user) => user.value?.storeInfoOf(widget.storeId)?.name,
      ),
    );

    return Scaffold(
      backgroundColor: context.systemGroupedBackground,
      appBar: CustomAppBar(
        title: '점포 별명',
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
              '비워 두면 점포 이름이 보입니다. 점포 별명은 다른 멤버의 화면에 보이지 않습니다.',
            ),
            children: [
              TitleTextField(
                title: '점포 별명',
                placeholder: storeName,
                controller: _controller,
                autofocus: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxStoreNameCharCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
