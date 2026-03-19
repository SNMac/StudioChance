import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/invite_code_verification_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/memo_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_navigation_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/loading_overlay.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class InviteCodeVerifiedScreen extends ConsumerStatefulWidget {
  const InviteCodeVerifiedScreen({super.key});

  @override
  ConsumerState<InviteCodeVerifiedScreen> createState() =>
      _InviteCodeVerifiedScreenState();
}

class _InviteCodeVerifiedScreenState
    extends ConsumerState<InviteCodeVerifiedScreen> {
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final provider = inviteCodeVerificationControllerProvider;
    final state = ref.watch(provider);

    // 이 화면 도달 시 store는 non-null 보장
    final store = state.status.value;
    final isLoading = state.status.isLoading;

    final adminName =
        store?.memberInfos
            .where((m) => m.role == UserRole.admin)
            .firstOrNull
            ?.user
            .name ??
        '';

    final address = store != null
        ? '${store.address} ${store.addressDetail}'.trim()
        : '';

    return Scaffold(
      appBar: CustomAppBar(
        title: '점포 확인',
        actions: [AppBarActionButton(label: '확인')],
      ),
      body: Stack(
        children: [
          SafeAreaWithPadding(
            child: Column(
              spacing: 20,
              children: [
                GroupedFormContainer(
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('초대받은 점포가 맞는지 확인해주세요', style: textTheme.titleLarge),
                      const SizedBox(height: 12),
                    ],
                  ),
                  children: [
                    TitleTextLabel(title: '점포명', content: store?.name ?? ''),
                    TitleTextLabel(title: '대표 관리자', content: adminName),
                    TitleNavigationButton(
                      title: '주소',
                      content: address,
                      isChangeable: false,
                      onPressed: () {},
                    ),
                  ],
                ),

                GroupedFormContainer(
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '사용자 설정',
                        style: textTheme.labelLarge?.copyWith(
                          color: context.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    TitleTextField(
                      title: '점포 별명',
                      placeholder: store?.name ?? '',
                    ),
                    TitleNavigationButton(title: '색상', onPressed: () {}),
                    MemoTextField(
                      placeholder: '메모',
                      controller: _memoController,
                      maxLength: maxMemoCharCount,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(maxMemoCharCount),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          LoadingOverlay(isLoading: isLoading),
        ],
      ),
    );
  }
}
