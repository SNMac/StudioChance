import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/router/router_path.dart';

class InviteCodeVerifiedScreen extends ConsumerStatefulWidget {
  const InviteCodeVerifiedScreen({super.key});

  @override
  ConsumerState<InviteCodeVerifiedScreen> createState() =>
      _InviteCodeVerifiedScreenState();
}

class _InviteCodeVerifiedScreenState
    extends ConsumerState<InviteCodeVerifiedScreen> {
  late final TextEditingController _storeAliasController;
  late final TextEditingController _memoController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(inviteCodeVerificationControllerProvider);
    // 점포 별명 기본값(= 점포명)은 초대 코드 조회 성공 시 컨트롤러가 채워 둔다.
    _storeAliasController = TextEditingController(
      text: initialState.storeAlias,
    );
    _memoController = TextEditingController(text: initialState.memo);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _storeAliasController.dispose();
    _memoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String content) {
    showCustomAlertDialog(
      context: context,
      title: title,
      content: content,
      showCancel: false,
      confirmText: '확인',
    );
  }

  /// 신청 완료 후 이동
  /// - 마이페이지 플로우: 마이페이지로 복귀
  /// - 온보딩 플로우: currentUser 무효화로 라우터 redirect가 홈으로 보낸다
  void _onSubmitSucceeded() {
    final isFromMyPage = GoRouterState.of(
      context,
    ).uri.path.startsWith(SCRoute.myPage.fullPath);

    showCustomAlertDialog(
      context: context,
      title: '가입 신청이 접수되었습니다',
      content: '관리자가 승인하면 점포를 이용할 수 있어요.',
      showCancel: false,
      confirmText: '확인',
      onConfirmAfterPop: () {
        ref
            .read(inviteCodeVerificationControllerProvider.notifier)
            .completeJoin();
        if (!context.mounted || !isFromMyPage) return;
        context.go(SCRoute.myPage.fullPath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final provider = inviteCodeVerificationControllerProvider;
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // 이 화면 도달 시 store는 non-null 보장
    final store = state.status.value;
    final isLoading = state.submitStatus.isLoading;

    ref.listen(provider.select((value) => value.submitStatus), (
      previous,
      next,
    ) {
      // 제출을 시작했을 때만 처리한다 (초기 AsyncData(null)와 제출 성공 구별)
      if (previous?.isLoading != true) return;

      next.whenOrNull(
        data: (_) => _onSubmitSucceeded(),
        error: (error, _) {
          if (error is AppException) {
            _showErrorDialog(error.title, error.content);
          } else {
            _showErrorDialog(
              '에러가 발생했습니다',
              '개발자에게 문의해 주세요.\n(${error.toString()})',
            );
          }
        },
      );
    });

    final adminName =
        store?.memberInfos
            .where((m) => m.role == UserRole.admin)
            .firstOrNull
            ?.user
            .name ??
        '';

    final address = store != null
        ? '${store.address} ${store.addressDetail}'.trim()
        : '';

    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '점포 확인',
          leading: AppBarNaviBackButton(isEnabled: !isLoading),
          actions: [
            AppBarActionButton(
              label: '확인',
              onPressed: state.canSubmit
                  ? () async => notifier.submitJoinRequest()
                  : null,
            ),
          ],
        ),
        body: Stack(
          children: [
            Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: SafeAreaWithPadding(
                  child: Column(
                    spacing: 20,
                    children: [
                      GroupedFormContainer(
                        header: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '초대받은 점포가 맞는지 확인해주세요',
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                        children: [
                          TitleTextLabel(
                            title: '점포명',
                            content: store?.name ?? '',
                          ),
                          TitleTextLabel(title: '대표 관리자', content: adminName),
                          TitleNavigationButton(
                            title: '주소',
                            content: address,
                            isChangeable: false,
                            onPressed: () {},
                          ),
                        ],
                      ),

                      GroupedFormContainer(
                        header: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '사용자 설정',
                              style: textTheme.labelLarge?.copyWith(
                                color: context.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          TitleTextField(
                            title: '점포 별명',
                            placeholder: store?.name ?? '',
                            controller: _storeAliasController,
                            onChanged: notifier.setStoreAlias,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(15),
                            ],
                          ),
                          TitleNavigationButton(
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
                            onPressed: () =>
                                SCRoute.storeColor.pushChild(context),
                          ),
                          MemoTextField(
                            placeholder: '메모',
                            controller: _memoController,
                            onChanged: notifier.setMemo,
                            maxLength: maxMemoCharCount,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                maxMemoCharCount,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            LoadingOverlay(isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
