import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/onboarding/widgets/large_selection_button.dart';
import 'package:studio_chance/router/router_path.dart';

class AdminStoreRegistrationScreen extends StatelessWidget {
  const AdminStoreRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: '점포 등록'),
      body: SafeAreaWithPadding(
        child: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              spacing: 32,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LargeSelectionButton(
                  title: '점포 생성',
                  description: '관리자 역할로 점포 생성',
                  isNavigation: true,
                  onPressed: () => SCRoute.storeCreation.pushChild(context),
                ),
                LargeSelectionButton(
                  title: '초대 코드 입력',
                  description: '관리자 역할로 점포 입장',
                  isNavigation: true,
                  onPressed: () => SCRoute.inviteCodeForm.pushChild(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
