import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/components/app_bar_action_button.dart';
import 'package:studio_chance/presentation/components/app_bar_back_button.dart';
import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/components/store_input/view_models/store_input_form_view_model.dart';
import 'package:studio_chance/presentation/components/store_input/views/store_input_form_view.dart';
import 'package:studio_chance/presentation/onboarding/sessions/onboarding_session.dart';

class OnboardingStoreView extends ConsumerWidget {
  const OnboardingStoreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionStore = ref.watch(onboardingSessionProvider).storeToMake;

    final formProvider = storeInputFormViewModelProvider(sessionStore);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: '점포 등록',
        leading: const AppBarBackButton(),
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: formState.isValid
                ? () {
                    final result = formNotifier.getFormData();
                    if (result != null) {}
                  }
                : null,
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: Column(
          children: [StoreInputFormView(initialStore: sessionStore)],
        ),
      ),
    );
  }
}
