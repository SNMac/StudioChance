import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/commons/widgets/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form_body_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form_body_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class StoreAddressInputScreen extends ConsumerWidget {
  const StoreAddressInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '주소 입력',
        actions: [AppBarActionButton(label: '완료', onPressed: () {})],
      ),
      body: SafeAreaWithPadding(
        child: GroupedFormContainer(
          children: [
            InputFormBodyButton(placeholder: '주소', onPressed: () {}),
            InputFormBodyTextField(
              placeholder: '찾아오는 길 안내',
              maxLines: null,
              keyboardType: TextInputType.streetAddress,
            ),
          ],
        ),
      ),
    );
  }
}
