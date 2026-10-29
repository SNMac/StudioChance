import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/commons/store_input/screens/store_color_selection_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/my_store_settings_controller.dart';

/// 점포 상세 '내 설정'의 점포 색상 — 점포 폼 색상 화면을 내 설정 저장에 연결해 재사용한다
class MyStoreColorScreen extends ConsumerWidget {
  const MyStoreColorScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(
      currentUserProvider.select(
        (user) => user.value?.storeInfoOf(storeId)?.color,
      ),
    );

    return StoreColorSelectionScreen(
      selected: color,
      // 화면은 고르는 즉시 닫힌다. 저장 실패는 마이페이지가 알린다
      onSelected: (color) => ref
          .read(myStoreSettingsControllerProvider.notifier)
          .updateColor(storeId: storeId, color: color),
    );
  }
}
