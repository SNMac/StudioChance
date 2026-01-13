import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/components/app_bar_action_button.dart';
import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/components/store_input/view_models/store_input_form_view_model.dart';
import 'package:studio_chance/presentation/components/store_input/views/store_input_form_view.dart';
import 'package:studio_chance/presentation/onboarding/view_models/store_creation_controller.dart';

class StoreCreationView extends ConsumerWidget {
  const StoreCreationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formProvider = storeInputFormViewModelProvider(
      initialStore: null,
      initialColor: null,
    );
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    final submitState = ref.watch(storeCreationControllerProvider);
    final submitController = ref.read(storeCreationControllerProvider.notifier);

    ref.listen(storeCreationControllerProvider, (previous, next) {
      if (next.hasError) {
        // 에러 다이얼로그 표시 로직...
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: '점포 생성',
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: formState.isValid
                ? () {
                    // 1. 폼 데이터 가져오기 (Record 타입 반환)
                    final data = formNotifier.getFormData();

                    if (data != null) {
                      // 2. 컨트롤러에게 제출 위임
                      submitController.submit(data);
                    }
                  }
                : null,
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: Column(
          children: [
            StoreInputFormView(provider: formProvider),
            if (submitState.isLoading)
              const Center(child: CircularProgressIndicator.adaptive()),
          ],
        ),
      ),
    );
  }
}
