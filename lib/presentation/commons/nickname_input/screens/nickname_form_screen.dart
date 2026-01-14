import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/nickname_input/controllers/nickname_form_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form_body_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class NicknameFormScreen extends ConsumerStatefulWidget {
  /// 초기 닉네임 (수정 모드일 때 사용)
  final String? initialNickname;

  /// 앱바 제목 (기본값: '닉네임 설정')
  final String title;

  /// 완료 버튼 텍스트 (기본값: '완료')
  final String submitLabel;

  /// 완료 버튼 눌렀을 때 실행될 콜백 (입력된 닉네임을 전달)
  final Future<void> Function(String nickname) onComplete;

  /// 뒤로가기 제스처 허용 여부 (온보딩: false, 수정: true)
  final bool enableBackGesture;

  /// 뒤로가기 버튼/제스처 발생 시 실행될 커스텀 로직
  /// null이면 기본 pop 수행
  final VoidCallback? onBackPress;

  const NicknameFormScreen({
    super.key,
    this.initialNickname,
    this.title = '닉네임 변경',
    this.submitLabel = '완료',
    required this.onComplete,
    this.enableBackGesture = true,
    this.onBackPress,
  });

  @override
  ConsumerState<NicknameFormScreen> createState() => _NicknameFormScreenState();
}

class _NicknameFormScreenState extends ConsumerState<NicknameFormScreen> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBackPress != null) {
      widget.onBackPress!();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = nicknameFormControllerProvider(widget.initialNickname);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return PopScope(
      canPop: widget.enableBackGesture,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.title,
          // 커스텀 Back 동작 연결
          leading: AppBarNaviBackButton(onPressed: _handleBack),
          actions: [
            AppBarActionButton(
              label: widget.submitLabel,
              onPressed: state.isValid
                  ? () => widget.onComplete(state.nickname)
                  : null,
            ),
          ],
        ),
        body: SafeAreaWithPadding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '사용하실 닉네임을 입력해주세요',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GroupedFormContainer(
                    children: [
                      InputFormBodyTextField(
                        controller: _nicknameController,
                        maxLines: 1,
                        autofocus: true,
                        showClearButton: true,
                        placeholder: '닉네임',
                        onChanged: notifier.onNicknameChanged,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Text(
                      '10자 이내 한글·영문·숫자 사용가능\n띄어쓰기, 특수문자 사용 불가',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel,
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
