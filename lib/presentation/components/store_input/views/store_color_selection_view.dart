import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/presentation/components/app_bar_action_button.dart';
import 'package:studio_chance/presentation/components/custom_app_bar.dart';
import 'package:studio_chance/presentation/components/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/components/store_input/views/store_color_input_view.dart';

class StoreColorSelectionView extends ConsumerWidget {
  const StoreColorSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '색상 선택',
        actions: [AppBarActionButton(label: '완료', onPressed: () {})],
      ),
      body: SafeAreaWithPadding(
        child: Column(children: [StoreColorInputView()]),
      ),
    );
  }
}
