import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/presentation/components/grouped_form_container.dart';
import 'package:studio_chance/presentation/components/input_form_body_text_field.dart';
import 'package:studio_chance/presentation/components/input_form_title_navigation_button.dart';
import 'package:studio_chance/presentation/components/input_form_title_text_field.dart';
import 'package:studio_chance/presentation/components/store_input/view_models/store_input_form_view_model.dart';
import 'package:studio_chance/router/router_path.dart';

class StoreInputFormView extends ConsumerStatefulWidget {
  final StoreInputFormViewModelProvider provider;

  const StoreInputFormView({super.key, required this.provider});

  @override
  ConsumerState<StoreInputFormView> createState() => _StoreInputFormViewState();
}

class _StoreInputFormViewState extends ConsumerState<StoreInputFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();

    final initialState = ref.read(widget.provider);
    _nameController = TextEditingController(text: initialState.name);
    _memoController = TextEditingController(text: initialState.memo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);
    final notifier = ref.read(widget.provider.notifier);

    return GroupedFormContainer(
      children: [
        InputFormTitleTextField(
          title: '점포명',
          controller: _nameController,
          onChanged: notifier.setName,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
        ),

        InputFormTitleNavigationButton(
          title: '색상',
          content: state.color.displayName,
          contentLeading: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(state.color.foregroundColorValue),
              shape: BoxShape.circle,
            ),
          ),
          onPressed: () {
            context.push(SCRoute.onboardingStoreColor.fullPath);
          },
        ),

        InputFormTitleNavigationButton(
          title: '주소',
          content: state.address.isEmpty ? '주소 검색' : state.address,
          onPressed: () async {
            // 임시 주소 입력 (실제 구현 시 API 연동)
            final result = await _showAddressInput(context, state.address);
            if (result != null && result.isNotEmpty) {
              notifier.setAddress(result);
            }
          },
        ),

        InputFormBodyTextField(
          placeholder: '메모',
          controller: _memoController,
          onChanged: notifier.setMemo,
          maxLines: null,
          inputFormatters: [LengthLimitingTextInputFormatter(150)],
        ),
      ],
    );
  }

  Future<String?> _showAddressInput(BuildContext context, String current) {
    String temp = current;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주소 입력'),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: current),
          onChanged: (v) => temp = v,
          decoration: const InputDecoration(hintText: '주소를 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, temp),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
