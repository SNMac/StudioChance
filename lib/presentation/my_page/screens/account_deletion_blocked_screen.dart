import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/commons/widgets/store_color_dot.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/router/router_path.dart';

/// 계정 삭제가 막혔을 때의 안내 — 다른 멤버가 있는 관리자 점포를 보여주고,
/// 행을 탭하면 그 점포 상세에서 관리자 위임이나 점포 삭제를 하게 한다.
///
/// [stores]는 `StoreAdminHandoverRequiredException.stores`다. 위임을 마친 점포는 내 역할이
/// 관리자가 아니게 되고, 삭제한 점포는 삭제 예정 점포가 되어 계정 삭제를 막지 않으므로
/// 목록에서 빠진다 (ADR-0007).
class AccountDeletionBlockedScreen extends ConsumerWidget {
  const AccountDeletionBlockedScreen({super.key, required this.stores});

  final List<StoreRef> stores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // roleIn·storeInfoOf를 쓰므로 사용자 전체를 본다. 점포 몇 개짜리 안내 화면이라
    // 다시 그리는 비용이 작다
    final user = ref.watch(currentUserProvider).asData?.value;
    final textTheme = Theme.of(context).textTheme;
    final remaining = stores
        .where((store) => user?.storeInfoOf(store.id)?.canManageStore ?? false)
        .toList();

    return Scaffold(
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
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text('계정을 삭제하기 전에', style: textTheme.titleLarge),
                    Text(
                      remaining.isEmpty
                          ? '이제 계정을 삭제할 수 있습니다. 마이페이지에서 다시 시도해 주세요.'
                          : '다른 멤버가 있는 점포의 관리자입니다. 점포마다 관리자를 '
                                '위임하거나 점포를 삭제한 뒤 다시 시도해 주세요.',
                      style: textTheme.labelLarge?.copyWith(
                        color: context.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              if (remaining.isNotEmpty)
                GroupedFormContainer(
                  children: [
                    for (final store in remaining)
                      TitleNavigationButton(
                        title: user?.storeInfoOf(store.id)?.name ?? store.name,
                        titleLeading: switch (user?.storeInfoOf(store.id)) {
                          final info? => StoreColorDot(color: info.color),
                          null => null,
                        },
                        content: UserRole.admin.displayName,
                        isChangeable: true,
                        prioritizeContent: true,
                        onPressed: () =>
                            context.push(storeDetailLocation(store.id)),
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
