import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/store_deletion_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/string_extension.dart';
import 'package:studio_chance/presentation/commons/store_input/store_edit_launcher.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/app_toast.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_caption.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';
import 'package:studio_chance/presentation/commons/widgets/store_color_dot.dart';
import 'package:studio_chance/presentation/commons/widgets/store_deletion_notice.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
import 'package:studio_chance/presentation/providers/store_membership_controller.dart';
import 'package:studio_chance/router/router_path.dart';

/// 점포 상세 — 마이페이지 점포 행을 탭하면 연다. 내 역할에 따라 구성이 다르다.
///
/// - 관리자: 점포 정보 수정 · 승인 대기 / 내 설정 / 멤버(탭하면 역할 변경·추방) / 관리자 위임 · 점포 삭제
/// - 스태프·뷰어: 내 설정 / 멤버(읽기 전용) / 점포 나가기
///
/// 삭제 예정 점포는 읽기 전용이다 (ADR-0007). 맨 위에 남은 기간 안내를 두고 점포 관리와
/// 멤버 관리를 숨긴다.
/// - 관리자: 안내 / 내 설정 / 멤버(읽기 전용) / 점포 복구 · 영구 삭제
/// - 스태프·뷰어: 안내 / 내 설정 / 멤버(읽기 전용) / 점포 나가기
///
/// 실패 알림은 이 화면이 아니라 뒤에 깔린 마이페이지가 맡는다 (MyPageScreen의 리스너 주석)
class StoreDetailScreen extends ConsumerStatefulWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen>
    with StoreEditLauncher {
  String get _storeId => widget.storeId;

  @override
  Widget build(BuildContext context) {
    // 이 점포의 내 정보만 본다 (다른 점포 정보가 바뀌어도 다시 그리지 않는다)
    final (myUid, myInfo) = ref.watch(
      currentUserProvider.select((value) {
        final user = value.asData?.value;
        return (user?.id, user?.storeInfoOf(_storeId));
      }),
    );
    final storeAsync = ref.watch(storeDetailProvider(_storeId));
    final isWorking = ref.watch(
      storeMembershipControllerProvider.select((s) => s.isLoading),
    );

    // 나가기·삭제 직후나 다른 기기에서 추방된 뒤에는 더 이상 이 점포의 멤버가 아니다
    if (myUid == null || myInfo == null || myInfo.isPending) {
      return Scaffold(
        backgroundColor: context.systemGroupedBackground,
        appBar: const CustomAppBar(title: '점포'),
        body: const Center(child: Text('이 점포를 볼 수 없습니다')),
      );
    }

    final isAdmin = myInfo.role == UserRole.admin;
    final deletionDeadline = myInfo.deletionDeadline;
    final isScheduledForDeletion = deletionDeadline != null;
    final store = storeAsync.asData?.value;
    final storeName = store?.name ?? myInfo.name;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: context.systemGroupedBackground,
          appBar: CustomAppBar(title: store?.name ?? myInfo.name),
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
                  if (deletionDeadline != null)
                    StoreDeletionNotice(
                      title:
                          '${deletionDeadline.remainingUntilDeletion(DateTime.now())} 삭제됩니다',
                      message: isAdmin
                          ? '삭제되기 전에 복구하면 예약과 멤버가 그대로 돌아옵니다. '
                                '그때까지 예약을 추가하거나 고칠 수 없습니다.'
                          : '관리자가 그 전에 복구하면 예약과 멤버가 그대로 돌아옵니다. '
                                '그때까지 예약을 추가하거나 고칠 수 없습니다.',
                    ),

                  if (isAdmin && !isScheduledForDeletion)
                    GroupedFormContainer(
                      children: [
                        TitleNavigationButton(
                          title: '점포 정보 수정',
                          onPressed: () => openStoreEdit(_storeId),
                        ),
                        TitleNavigationButton(
                          title: '승인 대기',
                          content: '${store?.waitingMemberInfos.length ?? 0}명',
                          isChangeable: true,
                          onPressed: () =>
                              showPendingMemberModal(context, _storeId),
                        ),
                      ],
                    ),

                  _MySettingsSection(info: myInfo),

                  _MembersSection(
                    store: store,
                    isLoading: storeAsync.isLoading,
                    myUid: myUid,
                    // 삭제 예정 점포에서는 멤버 관리를 할 수 없다
                    canManageMembers: isAdmin && !isScheduledForDeletion,
                    onMemberPressed: (member) =>
                        _showMemberActions(context, member),
                  ),

                  GroupedFormContainer(
                    children: isAdmin && isScheduledForDeletion
                        ? [
                            TextActionButton(
                              title: '점포 복구',
                              onPressed: isWorking ? null : _restoreStore,
                            ),
                            TextActionButton(
                              title: '영구 삭제',
                              isDestructive: true,
                              onPressed: isWorking
                                  ? null
                                  : () => _confirmPermanentlyDeleteStore(
                                      context,
                                      storeName,
                                    ),
                            ),
                          ]
                        : isAdmin
                        ? [
                            // 다른 멤버가 없으면 위임할 대상이 없다 (그때는 계정 삭제도 막히지 않는다)
                            if ((store?.memberInfos.length ?? 0) > 1)
                              TextActionButton(
                                title: '관리자 위임',
                                isDestructive: true,
                                onPressed: isWorking
                                    ? null
                                    : () => SCRoute.delegateAdmin.pushChild(
                                        context,
                                      ),
                              ),
                            TextActionButton(
                              title: '점포 삭제',
                              isDestructive: true,
                              onPressed: isWorking
                                  ? null
                                  : () =>
                                        _confirmDeleteStore(context, storeName),
                            ),
                          ]
                        : [
                            TextActionButton(
                              title: '점포 나가기',
                              isDestructive: true,
                              onPressed: isWorking
                                  ? null
                                  : () => _confirmLeave(context, storeName),
                            ),
                          ],
                  ),
                ],
              ),
            ),
          ),
        ),
        LoadingOverlay(isLoading: showStoreEditOverlay || isWorking),
      ],
    );
  }

  /// 관리자가 다른 멤버 행을 탭했을 때. 역할 변경은 되돌리기 쉬워 확인 없이 바로 적용한다
  void _showMemberActions(BuildContext context, StoreMemberInfo member) {
    final name = member.user.displayName;
    final newRole = member.role == UserRole.staff
        ? UserRole.viewer
        : UserRole.staff;
    final controller = ref.read(storeMembershipControllerProvider.notifier);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(name),
        message: Text(member.role.displayName),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              sheetContext.pop();
              final succeeded = await controller.changeRole(
                storeId: _storeId,
                uid: member.user.id,
                newRole: newRole,
              );
              if (succeeded && context.mounted) {
                showAppToast(context, '$name 님을 ${newRole.displayName}로 바꿨습니다');
              }
            },
            child: Text('${newRole.displayName}로 변경'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              sheetContext.pop();
              _confirmRemove(context, member);
            },
            child: const Text('추방'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => sheetContext.pop(),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, StoreMemberInfo member) {
    final name = member.user.displayName;
    showCustomAlertDialog(
      context: context,
      title: '$name 님을 추방할까요?',
      content: '추방하면 이 점포의 정보와 예약을 볼 수 없게 됩니다.',
      confirmText: '추방',
      isDestructive: true,
      onConfirmAfterPop: () async {
        await ref
            .read(storeMembershipControllerProvider.notifier)
            .removeMember(storeId: _storeId, uid: member.user.id);
      },
    );
  }

  /// 점포 삭제. 삭제 예정 점포는 계속 볼 수 있지만 상세 화면은 닫는다. 영구 삭제는
  /// 점포 상세에 다시 들어와서 하게 해 삭제와 영구 삭제를 잇달아 누르지 않게 한다 (ADR-0007)
  void _confirmDeleteStore(BuildContext context, String storeName) {
    _confirmThenClose(
      context,
      title: '${storeName.withObjectParticle()} 삭제할까요?',
      content:
          '$storeSoftDeleteDays일 후 점포와 예약이 지워집니다. 그때까지 예약을 추가하거나 '
          '고칠 수 없고, 점포 상세에서 복구할 수 있습니다.',
      confirmText: '삭제',
      action: (controller) => controller.deleteStore(_storeId),
    );
  }

  /// 점포 복구는 되돌려도 잃는 것이 없어 확인 없이 바로 한다
  Future<void> _restoreStore() async {
    final succeeded = await ref
        .read(storeMembershipControllerProvider.notifier)
        .restoreStore(_storeId);
    if (succeeded && mounted) showAppToast(context, '점포를 복구했습니다');
  }

  void _confirmPermanentlyDeleteStore(BuildContext context, String storeName) {
    _confirmThenClose(
      context,
      title: '${storeName.withObjectParticle()} 영구 삭제할까요?',
      content: '점포와 예약이 바로 지워지고 모든 멤버의 점포 목록에서 사라집니다. 되돌릴 수 없습니다.',
      confirmText: '영구 삭제',
      action: (controller) => controller.permanentlyDeleteStore(_storeId),
    );
  }

  void _confirmLeave(BuildContext context, String storeName) {
    _confirmThenClose(
      context,
      title: '$storeName에서 나갈까요?',
      content: '나가면 이 점포의 정보와 예약을 볼 수 없습니다. 다시 들어오려면 초대 코드로 가입을 신청해야 합니다.',
      confirmText: '나가기',
      action: (controller) => controller.leaveStore(_storeId),
    );
  }

  /// 확인을 받아 [action]을 하고, 성공하면 상세 화면을 닫는다.
  ///
  /// `go`가 아니라 `pop`으로 닫아 들어온 화면(마이페이지 또는 계정 삭제 안내)으로 돌아간다.
  /// 안내 화면에서 왔다면 남은 막힌 점포를 이어서 처리할 수 있다
  void _confirmThenClose(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Future<bool> Function(StoreMembershipController controller) action,
  }) {
    showCustomAlertDialog(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      isDestructive: true,
      onConfirmAfterPop: () async {
        final succeeded = await action(
          ref.read(storeMembershipControllerProvider.notifier),
        );
        if (succeeded && context.mounted) context.pop();
      },
    );
  }
}

/// 내 설정 — 점포 색상·점포 메모. 멤버마다 따로 두는 값이라 역할과 관계없이 바꾼다
class _MySettingsSection extends StatelessWidget {
  const _MySettingsSection({required this.info});

  final UserStoreInfo info;

  @override
  Widget build(BuildContext context) {
    return GroupedFormContainer(
      header: const GroupedFormCaption.header('내 설정'),
      children: [
        TitleNavigationButton(
          title: '점포 색상',
          content: info.color.displayName,
          contentLeading: StoreColorDot(color: info.color),
          isChangeable: true,
          onPressed: () => SCRoute.storeColor.pushChild(context),
        ),
        TitleNavigationButton(
          title: '점포 메모',
          // 여러 줄 메모는 첫 줄만 보여준다
          content: info.memo.split('\n').first,
          isChangeable: true,
          onPressed: () => SCRoute.storeMemo.pushChild(context),
        ),
      ],
    );
  }
}

/// 멤버 목록. 멤버를 관리할 수 있으면 내가 아닌 행을 탭할 수 있다
class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.store,
    required this.isLoading,
    required this.myUid,
    required this.canManageMembers,
    required this.onMemberPressed,
  });

  final Store? store;
  final bool isLoading;
  final String myUid;

  /// 관리자이고 점포가 삭제 예정이 아닐 때만 멤버 행을 탭해 역할 변경·추방을 한다
  final bool canManageMembers;
  final ValueChanged<StoreMemberInfo> onMemberPressed;

  @override
  Widget build(BuildContext context) {
    final store = this.store;
    if (store == null) {
      return GroupedFormContainer(
        header: const GroupedFormCaption.header('멤버'),
        children: [
          SizedBox(
            height: 48,
            child: Center(
              child: isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text('멤버를 불러오지 못했습니다'),
            ),
          ),
        ],
      );
    }

    final members = store.sortedMemberInfos;

    return GroupedFormContainer(
      header: GroupedFormCaption.header('멤버 ${members.length}명'),
      footer: canManageMembers && members.length > 1
          ? const GroupedFormCaption.footer('멤버를 탭하면 역할을 바꾸거나 추방할 수 있습니다.')
          : null,
      children: [
        for (final member in members)
          TitleNavigationButton(
            title: member.user.id == myUid
                ? '${member.user.displayName} (나)'
                : member.user.displayName,
            content: member.role.displayName,
            isChangeable: true,
            prioritizeContent: true,
            showChevron: false,
            onPressed:
                canManageMembers &&
                    member.user.id != myUid &&
                    member.role != UserRole.admin
                ? () => onMemberPressed(member)
                : null,
          ),
      ],
    );
  }
}
