import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
import 'package:studio_chance/presentation/commons/nickname_input/screens/nickname_form_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';
import 'package:studio_chance/presentation/onboarding/controllers/onboarding_nickname_controller.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/pending_member_controller.dart';
import 'package:studio_chance/presentation/providers/sign_out_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
import 'package:studio_chance/router/router_path.dart';

/// [home_screen.dart]의 에러 다이얼로그 패턴과 동일하게, silentable하지 않은
/// 에러만 사용자에게 알린다.
void _showErrorDialog(BuildContext context, Object error) {
  if (!context.mounted) return;
  if (error is AppException && !error.isSilentable) {
    showCustomAlertDialog(
      context: context,
      title: error.title,
      content: error.content,
      showCancel: false,
    );
  } else if (error is! AppException) {
    showCustomAlertDialog(
      context: context,
      title: '오류',
      content: '잠시 후 다시 시도해 주세요.',
      showCancel: false,
    );
  }
}

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;

    // 승인/거절·로그아웃 실패를 사용자에게 알린다.
    // 모달(PendingMemberModal)은 사용자가 드래그로 먼저 닫아버릴 수 있어
    // 리스너를 걸어도 결과가 도착했을 때 이미 dispose됐을 수 있다.
    // MyPageScreen은 모달이 열려 있든 닫혀 있든 바텀시트 뒤에서 계속
    // mounted 상태로 남아 있으므로 여기서 듣는다.
    ref.listen(pendingMemberControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) => _showErrorDialog(context, e));
    });
    ref.listen(signOutControllerProvider, (_, next) {
      next.whenOrNull(error: (e, _) => _showErrorDialog(context, e));
    });

    return Scaffold(
      backgroundColor: context.systemGroupedBackground,
      appBar: const CustomAppBar(title: '마이페이지'),
      bottomNavigationBar: const HomeTabBar(),
      body: SingleChildScrollView(
        child: SafeAreaWithPadding(
          top: false,
          padding: const EdgeInsetsDirectional.fromSTEB(
            horizontalPadding,
            16,
            horizontalPadding,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              // 프로필
              GroupedFormContainer(
                children: [
                  TitleNavigationButton(
                    title: '닉네임',
                    content: user?.nickname ?? '',
                    isChangeable: true,
                    onPressed: () => SCRoute.nickname.pushChild(context),
                  ),
                  TitleNavigationButton(
                    title: '이메일',
                    content: user?.email ?? '',
                    onPressed: () {},
                  ),
                ],
              ),

              // 내 점포
              GroupedFormContainer(
                header: const _SectionHeader(title: '내 점포'),
                children: [
                  for (final info in user?.storeInfos ?? <UserStoreInfo>[])
                    _StoreRow(info: info),
                  TitleNavigationButton(
                    title: '점포 추가',
                    isChangeable: true,
                    onPressed: () => SCRoute.role.pushChild(context),
                  ),
                ],
              ),

              // 로그아웃
              GroupedFormContainer(
                children: [
                  TitleNavigationButton(
                    title: '로그아웃',
                    onPressed: () => showCustomAlertDialog(
                      context: context,
                      title: '로그아웃할까요?',
                      confirmText: '로그아웃',
                      isDestructive: true,
                      onConfirmAfterPop: () {
                        ref.read(signOutControllerProvider.notifier).signOut();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 그룹 상단 라벨
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(horizontalPadding, 0, 0, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: context.secondaryLabel),
      ),
    );
  }
}

/// 점포 한 줄. ADMIN 점포는 대기 인원을 함께 표시하고 탭하면 승인 대기 모달을 연다.
class _StoreRow extends ConsumerWidget {
  const _StoreRow({required this.info});

  final UserStoreInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = info.role == UserRole.admin;

    // 관리자인 점포만 대기 인원을 조회한다 (불필요한 Firestore 읽기 방지)
    final waitingCount = isAdmin
        ? ref
                  .watch(storeDetailProvider(info.id))
                  .asData
                  ?.value
                  ?.waitingMemberInfos
                  .length ??
              0
        : 0;

    final content = waitingCount > 0
        ? '${info.role.displayName} · 신청 $waitingCount'
        : info.role.displayName;

    return TitleNavigationButton(
      title: info.name,
      content: content,
      isChangeable: isAdmin,
      contentLeading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(info.color.foregroundColorValue),
        ),
      ),
      onPressed: isAdmin
          ? () => showPendingMemberModal(context, info.id)
          : () {},
    );
  }
}

/// 마이페이지 닉네임 변경 화면 — 온보딩과 동일한 폼을 재사용한다.
class MyPageNicknameScreen extends ConsumerWidget {
  const MyPageNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;

    return NicknameFormScreen(
      initialNickname: user?.nickname,
      title: '닉네임 변경',
      onComplete: (nickname) async {
        final notifier = ref.read(
          onboardingNicknameControllerProvider.notifier,
        );
        await notifier.saveNicknameToRemote(nickname);

        final state = ref.read(onboardingNicknameControllerProvider);
        if (state.hasError) return;

        ref.invalidate(currentUserProvider);
        if (context.mounted) context.pop();
      },
    );
  }
}
