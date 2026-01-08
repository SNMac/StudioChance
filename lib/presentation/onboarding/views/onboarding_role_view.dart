import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/components/app_bar_back_button.dart';

class OnboardingRoleView extends StatelessWidget {
  const OnboardingRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('역할 선택'), leading: AppBarBackButton()),
      // body: ,
    );
  }
}
