import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/views/components/selection_button.dart';
import 'package:studio_chance/router/router_path.dart';

class OnboardingAdminView extends StatelessWidget {
  const OnboardingAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '점포 등록'),
      body: SafeAreaWithPadding(
        child: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              spacing: 32,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectionButton(
                  title: '점포 생성',
                  description: '관리자 역할로 점포 생성',
                  isNavigation: true,
                  onPressed: () =>
                      context.push(SCRoute.onboardingStore.fullPath),
                ),
                SelectionButton(
                  title: '초대 코드 입력',
                  description: '관리자 역할로 점포 입장',
                  isNavigation: true,
                  onPressed: () =>
                      context.push(SCRoute.onboardingInvitation.fullPath),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
