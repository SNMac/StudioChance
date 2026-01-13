import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kpostal/kpostal.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
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
      appBar: CustomAppBar(
        title: '주소 입력',
        actions: [AppBarActionButton(label: '완료', onPressed: () {})],
      ),
      body: SafeAreaWithPadding(
        child: GroupedFormContainer(
          children: [
            InputFormBodyButton(
              placeholder: '주소',
              onPressed: () async {
                final Kpostal? result = await showCupertinoSheet<Kpostal>(
                  context: context,
                  builder: (context) {
                    return KpostalView();
                  },
                );

                if (result != null) {
                  notifier.setAddress(result.address);
                  notifier.setAddressShort(
                    result.bname.isEmpty ? result.sigungu : result.bname,
                  );
                }
              },
            ),
            InputFormBodyTextField(
              placeholder: '찾아오는 길 안내',
              maxLines: null,
              returnButtonType: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
