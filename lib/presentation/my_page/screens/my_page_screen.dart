import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_deletion_formatter.dart';
import 'package:studio_chance/presentation/commons/nickname_input/screens/nickname_save_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_caption.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';
import 'package:studio_chance/presentation/my_page/widgets/my_page_error_dialog.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_badge.dart';
import 'package:studio_chance/presentation/commons/widgets/store_color_dot.dart';
import 'package:studio_chance/presentation/providers/account_deletion_controller.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/invite_code_controller.dart';
import 'package:studio_chance/presentation/providers/my_store_settings_controller.dart';
import 'package:studio_chance/presentation/providers/pending_member_controller.dart';
import 'package:studio_chance/presentation/providers/sign_out_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
import 'package:studio_chance/presentation/providers/store_membership_controller.dart';
import 'package:studio_chance/router/router_path.dart';

/// 마이페이지 — 프로필, 내 점포, 로그아웃·계정 삭제.
///
/// 점포별 기능(점포 정보 수정·승인 대기·멤버 관리·나가기·삭제)은 점포 행을 탭해
/// 여는 점포 상세 화면에 있다.
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;
    final isDeletingAccount = ref.watch(
      accountDeletionControllerProvider.select((s) => s.isLoading),
    );

    // 마이페이지와 그 아래 화면(점포 상세·위임·내 설정, 승인 대기 모달)의 실패를 여기서
    // 한 번만 알린다. 마이페이지는 /my-page 아래 화면이 열려 있는 동안 그 뒤에서 계속
    // mounted 상태라, 아래 화면도 같은 컨트롤러를 들으면 다이얼로그가 두 번 뜬다.
    // 모달은 사용자가 먼저 닫아 버릴 수 있어 모달 쪽 리스너는 결과를 놓칠 수 있다.
    for (final provider in [
      signOutControllerProvider,
      storeMembershipControllerProvider,
      myStoreSettingsControllerProvider,
      pendingMemberControllerProvider,
      inviteCodeControllerProvider,
    ]) {
      ref.listen(provider, (_, next) {
        next.whenOrNull(error: (e, _) => showMyPageErrorDialog(context, e));
      });
    }
    ref.listen(accountDeletionControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          // 다른 멤버가 있는 관리자 점포가 남아 있으면 위임·삭제로 안내한다
          if (e is StoreAdminHandoverRequiredException) {
            context.push(
              SCRoute.accountDeletionBlocked.fullPath,
              extra: e.stores,
            );
            return;
          }
          showMyPageErrorDialog(context, e);
        },
      );
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: context.systemGroupedBackground,
          // 앱바를 두지 않는다 — 위치는 하단 탭바가 보여주고, 맨 위 프로필 카드가
          // 머리글 역할을 한다 (홈 화면도 제목 없이 시작한다)
          bottomNavigationBar: const HomeTabBar(),
          body: SingleChildScrollView(
            child: SafeAreaWithPadding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  _ProfileHeader(
                    user: user,
                    onPressed: () => SCRoute.nickname.pushChild(context),
                  ),

                  GroupedFormContainer(
                    header: const GroupedFormCaption.header('내 점포'),
                    children: [
                      for (final info in user?.storeInfos ?? <UserStoreInfo>[])
                        info.isPending
                            ? _PendingStoreRow(
                                info: info,
                                onCancel: () => _confirmCancelJoinRequest(
                                  context,
                                  ref,
                                  info,
                                ),
                              )
                            : _StoreRow(
                                info: info,
                                onPressed: () =>
                                    context.push(storeDetailLocation(info.id)),
                              ),
                      TitleNavigationButton(
                        title: '점포 추가',
                        onPressed: () => SCRoute.role.pushChild(context),
                      ),
                    ],
                  ),

                  GroupedFormContainer(
                    children: [
                      TextActionButton(
                        title: '로그아웃',
                        onPressed: () => showCustomAlertDialog(
                          context: context,
                          title: '로그아웃할까요?',
                          confirmText: '로그아웃',
                          isDestructive: true,
                          onConfirmAfterPop: () {
                            ref
                                .read(signOutControllerProvider.notifier)
                                .signOut();
                          },
                        ),
                      ),
                      TextActionButton(
                        title: '계정 삭제',
                        isDestructive: true,
                        onPressed: isDeletingAccount
                            ? null
                            : () => _confirmDeleteAccount(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        LoadingOverlay(isLoading: isDeletingAccount),
      ],
    );
  }

  void _confirmCancelJoinRequest(
    BuildContext context,
    WidgetRef ref,
    UserStoreInfo info,
  ) {
    showCustomAlertDialog(
      context: context,
      title: '${info.name} 가입 신청을 취소할까요?',
      content: '취소한 뒤에도 초대 코드로 다시 신청할 수 있습니다.',
      cancelText: '닫기',
      confirmText: '신청 취소',
      isDestructive: true,
      onConfirmAfterPop: () => ref
          .read(storeMembershipControllerProvider.notifier)
          .cancelJoinRequest(info.id),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showCustomAlertDialog(
      context: context,
      title: '계정을 삭제할까요?',
      content:
          '혼자 쓰던 점포와 삭제 예정인 점포는 바로 지워지고, 나머지 점포에서는 모두 나가며, '
          '승인 대기 중인 가입 신청은 취소됩니다. 삭제한 계정은 되돌릴 수 없습니다.',
      confirmText: '삭제',
      isDestructive: true,
      onConfirmAfterPop: () {
        ref.read(accountDeletionControllerProvider.notifier).delete();
      },
    );
  }
}

/// 닉네임(크게)과 이메일. 탭하면 닉네임을 바꾼다
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.onPressed});

  final User? user;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: onPressed,
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    user?.nickname ?? '',
                    style: textTheme.headlineSmall?.copyWith(
                      color: context.label,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.email ?? '',
                    style: textTheme.labelLarge?.copyWith(
                      color: context.secondaryLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 18,
              color: context.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// 멤버인 점포 행. 관리자 점포는 승인 대기 인원을 배지로 보여준다
class _StoreRow extends ConsumerWidget {
  const _StoreRow({required this.info, required this.onPressed});

  final UserStoreInfo info;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = info.role == UserRole.admin;
    final deletionDeadline = info.deletionDeadline;

    // 삭제 예정 점포는 역할 대신 남은 기간을 보여준다. 승인 대기 명단은 점포 삭제 때
    // 비웠으므로 대기 인원도 조회하지 않는다 (ADR-0007)
    if (deletionDeadline != null) {
      return TitleNavigationButton(
        title: info.name,
        titleLeading: StoreColorDot(color: info.color),
        content:
            '${deletionDeadline.remainingUntilDeletion(DateTime.now())} 삭제',
        contentColor: context.systemRed,
        isChangeable: true,
        prioritizeContent: true,
        onPressed: onPressed,
      );
    }

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

    return TitleNavigationButton(
      title: info.name,
      titleLeading: StoreColorDot(color: info.color),
      content: info.role.displayName,
      isChangeable: true,
      prioritizeContent: true,
      trailing: waitingCount > 0
          ? PendingMemberBadge(count: waitingCount)
          : null,
      onPressed: onPressed,
    );
  }
}

/// 승인 대기 점포 행. 멤버가 아니라 점포를 읽을 수 없으므로 상세 화면이 없고,
/// '신청 취소' 버튼만 동작한다
class _PendingStoreRow extends StatelessWidget {
  const _PendingStoreRow({required this.info, required this.onCancel});

  final UserStoreInfo info;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return TitleNavigationButton(
      title: info.name,
      titleLeading: StoreColorDot(color: info.color),
      content: '승인 대기',
      isChangeable: true,
      prioritizeContent: true,
      showChevron: false,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onCancel,
        child: Text(
          '신청 취소',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.systemBlue,
          ),
        ),
      ),
    );
  }
}

/// 마이페이지 닉네임 변경 화면 — 온보딩과 동일한 폼을 재사용한다.
class MyPageNicknameScreen extends ConsumerWidget {
  const MyPageNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;

    return NicknameSaveScreen(
      initialNickname: user?.nickname,
      title: '닉네임 변경',
      onError: (error) => showMyPageErrorDialog(context, error),
      onSaved: () {
        ref.invalidate(currentUserProvider);
        if (context.mounted) context.pop();
      },
    );
  }
}
