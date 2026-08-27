import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/body_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/router/router_path.dart';

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
    final textTheme = Theme.of(context).textTheme;

    final provider = inviteCodeVerificationControllerProvider;
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    final isLoading = state.status.isLoading;

    ref.listen(provider, (previous, next) {
      // 로딩 중이었을 때만 처리한다 (초기 null과 "없음" null 구별).
      // 이 컨트롤러의 state는 status 외에 코드 입력값도 들고 있어, 글자를 칠 때마다
      // listen이 발화한다. 가드 없이 error를 처리하면 이전 에러가 status에 남아 있는
      // 동안 입력할 때마다 같은 alert이 반복해서 뜬다.
      if (previous?.status.isLoading != true) return;

      next.status.whenOrNull(
        data: (store) {
          if (store != null) {
            SCRoute.inviteCodeVerified.pushChild(context);
          } else {
            showCustomAlertDialog(
              context: context,
              title: '점포를 찾을 수 없습니다',
              content: '초대 코드에 해당하는 점포가 없어요.\n코드를 다시 확인해 주세요.',
              showCancel: false,
              confirmText: '확인',
            );
          }
        },
        error: (error, _) {
          if (error is AppException) {
            showCustomAlertDialog(
              context: context,
              title: error.title,
              content: error.content,
              showCancel: false,
              confirmText: '확인',
            );
          } else {
            showCustomAlertDialog(
              context: context,
              title: '에러가 발생했습니다',
              content: '개발자에게 문의해 주세요.\n(${error.toString()})',
              showCancel: false,
              confirmText: '확인',
            );
          }
        },
      );
    });

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
                        Text('점포의 초대 코드를 입력해 주세요', style: textTheme.titleLarge),
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
                            style: textTheme.labelLarge?.copyWith(
                              color: context.secondaryLabel,
                            ),
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
