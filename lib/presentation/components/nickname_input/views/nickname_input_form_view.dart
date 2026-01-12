import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/components/body_text_field.dart';
import 'package:studio_chance/presentation/components/grouped_form_container.dart';
import 'package:studio_chance/presentation/components/nickname_input/view_models/nickname_input_form_view_model.dart';

class NicknameInputFormView extends ConsumerStatefulWidget {
  final String? initialNickname;

  const NicknameInputFormView({super.key, required this.initialNickname});

  @override
  ConsumerState<NicknameInputFormView> createState() =>
      _NicknameInputFormState();
}

class _NicknameInputFormState extends ConsumerState<NicknameInputFormView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = nicknameInputFormViewModelProvider(widget.initialNickname);
    final notifier = ref.read(provider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupedFormContainer(
          children: [
            BodyTextField(
              controller: _controller,
              maxLines: 1,
              autofocus: true,
              onChanged: (value) => notifier.onNicknameChanged(value),
              placeholder: '닉네임',
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                // 타이핑용 Loose Regex
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            '10자 이내 한글·영문·숫자 사용가능\n띄어쓰기, 특수문자 사용 불가',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel,
                context,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
