import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/body_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class InviteCodeInputScreen extends ConsumerStatefulWidget {
  const InviteCodeInputScreen({super.key});

  @override
  ConsumerState<InviteCodeInputScreen> createState() =>
      _InviteCodeInputScreenState();
}

class _InviteCodeInputScreenState extends ConsumerState<InviteCodeInputScreen> {
  late final TextEditingController _inviteCodeController;

  @override
  void initState() {
    super.initState();
    _inviteCodeController = TextEditingController();
    _inviteCodeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = inviteCodeVerificationControllerProvider;
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    final isLoading = state.status.isLoading;

    return Scaffold(
      appBar: CustomAppBar(
        title: '초대 코드 입력',
        leading: AppBarNaviBackButton(isEnabled: !isLoading),
        actions: [
          AppBarActionButton(
            label: '다음',
            onPressed: state.isValid && !isLoading
                ? () => notifier.verifyInviteCode()
                : null,
          ),
        ],
      ),
      body: PopScope(
        canPop: !isLoading,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop || isLoading) return;
          if (context.mounted && context.canPop()) context.pop();
        },

        child: Stack(
          children: [
            SafeAreaWithPadding(
              child: Column(
                children: [
                  GroupedFormContainer(
                    header: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '점포의 초대 코드를 입력해 주세요',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    footer: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '영문·숫자 6자',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: context.secondaryLabel),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      BodyTextField(
                        controller: _inviteCodeController,
                        maxLines: 1,
                        autofocus: true,
                        showClearButton: true,
                        placeholder: '초대 코드',
                        onChanged: (value) {
                          final upper = value.toUpperCase();
                          if (value != upper) {
                            _inviteCodeController.value = TextEditingValue(
                              text: upper,
                              selection: TextSelection.collapsed(
                                offset: upper.length,
                              ),
                            );
                          }
                          notifier.onCodeChanged(upper);
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),

            LoadingOverlay(isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
