import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/commons/widgets/store_color_dot.dart';
import 'package:studio_chance/presentation/providers/account_deletion_controller.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/router/router_path.dart';

/// 계정 삭제 전에 알리는 결과
const _accountDeletionWarning =
    '혼자 쓰던 점포와 삭제 예정인 점포는 바로 지워지고, 나머지 점포에서는 모두 나가며, '
    '승인 대기 중인 가입 신청은 취소됩니다. 작성한 예약이 남아 있는 동안에는 '
    '닉네임이 다른 멤버에게 보입니다. 삭제한 계정은 되돌릴 수 없습니다.';

/// 계정 삭제 화면. 막는 점포가 없으면 계정 삭제 확인을, 있으면 그 점포를 안내한다.
///
/// 안내에서는 다른 멤버가 있는 관리자 점포를 보여주고, 행을 탭하면 그 점포 상세에서
/// 관리자 위임이나 점포 삭제를 하게 한다. 위임을 마친 점포는 내 역할이 관리자가 아니게 되고,
/// 삭제한 점포는 삭제 예정 점포가 되어 계정 삭제를 막지 않으므로 목록에서 빠진다 (ADR-0007).
/// 다른 멤버를 모두 내보낸 점포도 막지 않으므로, 점포 상세에서 돌아오면 막는 점포를 다시 구한다.
/// 모두 빠지면 이 화면이 그대로 계정 삭제 확인이 된다.
///
/// [stores]는 마이페이지가 화면을 열기 전에 구한 막는 점포다. 그 뒤 멤버가 늘어 삭제가
/// 막히면 `StoreAdminHandoverRequiredException.stores`로 바꿔 다시 안내한다.
///
/// 실패는 스스로 알리지 않는다. 뒤에 깔린 마이페이지가 알린다 (MyPageScreen의 리스너 주석)
class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key, required this.stores});

  final List<StoreRef> stores;

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  late var _stores = widget.stores;

  @override
  Widget build(BuildContext context) {
    // 막힌 경우만 받아 안내를 바꾼다. 로딩 상태도 직전 오류를 `error`로 들고 있으므로
    // 오류 상태일 때만 본다 — 그러지 않으면 다시 삭제할 때 지난 막힘 목록이 되살아난다
    ref.listen(accountDeletionControllerProvider, (_, next) {
      if (next case AsyncError(
        error: final StoreAdminHandoverRequiredException e,
      )) {
        setState(() => _stores = e.stores);
      }
    });

    // roleIn·storeInfoOf를 쓰므로 사용자 전체를 본다. 점포 몇 개짜리 안내 화면이라
    // 다시 그리는 비용이 작다
    final user = ref.watch(currentUserProvider).asData?.value;
    final isDeletingAccount = ref.watch(
      accountDeletionControllerProvider.select((s) => s.isLoading),
    );
    final textTheme = Theme.of(context).textTheme;
    // 사용자를 아직 못 읽었으면 막힌 점포를 그대로 보여준다. 비어 있다고 보면 삭제 확인이 먼저 뜬다
    final remaining = user == null
        ? _stores
        : _stores
              .where(
                (store) => user.storeInfoOf(store.id)?.canManageStore ?? false,
              )
              .toList();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: context.systemGroupedBackground,
          appBar: const CustomAppBar(title: '계정 삭제'),
          body: SingleChildScrollView(
            child: SafeAreaWithPadding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          remaining.isEmpty ? '계정을 삭제할까요?' : '계정을 삭제하기 전에',
                          style: textTheme.titleLarge,
                        ),
                        Text(
                          remaining.isEmpty
                              ? _accountDeletionWarning
                              : '다른 멤버가 있는 점포의 관리자입니다. 점포마다 관리자를 '
                                    '위임하거나 점포를 삭제하면 계정을 삭제할 수 있습니다.',
                          style: textTheme.labelLarge?.copyWith(
                            color: context.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (remaining.isEmpty)
                    GroupedFormContainer(
                      children: [
                        TextActionButton(
                          title: '계정 삭제',
                          isDestructive: true,
                          onPressed: isDeletingAccount
                              ? null
                              : () => ref
                                    .read(
                                      accountDeletionControllerProvider
                                          .notifier,
                                    )
                                    .delete(),
                        ),
                      ],
                    )
                  else
                    GroupedFormContainer(
                      children: [
                        for (final store in remaining)
                          TitleNavigationButton(
                            title:
                                user?.storeInfoOf(store.id)?.displayName ??
                                store.name,
                            titleLeading: switch (user?.storeInfoOf(store.id)) {
                              final info? => StoreColorDot(color: info.color),
                              null => null,
                            },
                            content: UserRole.admin.displayName,
                            isChangeable: true,
                            prioritizeContent: true,
                            onPressed: () => _openStore(store.id),
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

  /// 점포 상세에서 위임·점포 삭제·멤버 정리를 하고 돌아오면 막는 점포를 다시 구한다.
  /// 멤버를 모두 내보낸 것은 사용자 정보에 드러나지 않아 화면만으로는 알 수 없다
  Future<void> _openStore(String storeId) async {
    await context.push(storeDetailLocation(storeId));
    if (!mounted) return;

    final stores = await ref
        .read(accountDeletionControllerProvider.notifier)
        .findStoresBlockingDeletion();
    if (stores != null && mounted) setState(() => _stores = stores);
  }
}
