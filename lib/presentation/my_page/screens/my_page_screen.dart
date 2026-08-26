import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/home/widgets/home_tab_bar.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.systemGroupedBackground,
      appBar: const CustomAppBar(title: '마이페이지'),
      body: const SafeAreaWithPadding(top: false, child: SizedBox.shrink()),
      bottomNavigationBar: const HomeTabBar(),
    );
  }
}

/// 닉네임 변경 화면 — Task 13에서 `NicknameFormScreen` 재사용 구현으로 교체된다.
class MyPageNicknameScreen extends ConsumerWidget {
  const MyPageNicknameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
