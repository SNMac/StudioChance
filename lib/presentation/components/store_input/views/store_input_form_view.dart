import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/presentation/components/body_text_field.dart';
import 'package:studio_chance/presentation/components/grouped_form_container.dart';
import 'package:studio_chance/presentation/components/store_input/view_models/store_input_form_view_model.dart';
import 'package:studio_chance/presentation/components/title_navigation_button.dart';
import 'package:studio_chance/presentation/components/title_text_field.dart';

class StoreInputFormView extends ConsumerStatefulWidget {
  final Store? initialStore;
  final StoreColor? initialColor;

  const StoreInputFormView({
    super.key,
    required this.initialStore,
    this.initialColor,
  });

  @override
  ConsumerState<StoreInputFormView> createState() => _StoreInputFormViewState();
}

class _StoreInputFormViewState extends ConsumerState<StoreInputFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialStore?.name ?? '',
    );
    _memoController = TextEditingController(
      text: widget.initialStore?.memo ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = storeInputFormViewModelProvider(
      initialStore: widget.initialStore,
      initialColor: widget.initialColor,
    );
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return GroupedFormContainer(
      children: [
        TitleTextField(
          title: '점포명',
          controller: _nameController,
          onChanged: notifier.setName,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
        ),

        TitleNavigationButton(
          title: '주소',
          content: state.address.isEmpty ? '주소 검색' : state.address,
          onPressed: () async {
            // 임시 주소 입력 다이얼로그 (나중에 실제 주소 검색으로 교체)
            final result = await _showAddressInput(context, state.address);
            if (result != null && result.isNotEmpty) {
              notifier.setAddress(result);
            }
          },
        ),

        BodyTextField(
          placeholder: '메모',
          controller: _memoController,
          onChanged: notifier.setMemo,
          maxLines: null,
          inputFormatters: [LengthLimitingTextInputFormatter(150)],
        ),
      ],
    );
  }

  /// (임시) 주소 입력용 다이얼로그
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
