import 'package:flutter/material.dart';

import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class InviteCodeVerifiedScreen extends StatelessWidget {
  const InviteCodeVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '점포 확인',
        actions: [AppBarActionButton(label: '확인')],
      ),
      body: SafeAreaWithPadding(
        child: Column(
          children: [
            GroupedFormContainer(
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '초대받은 점포가 맞는지 확인해주세요',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
