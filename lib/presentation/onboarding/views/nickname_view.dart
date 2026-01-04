import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/domain/usecases/auth_use_case.dart';

class NicknameView extends ConsumerWidget {
  const NicknameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 타이틀 텍스트
    const titleTextWidget = Text(
      '닉네임 설정',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );

    // '다음' 버튼 텍스트
    const nextTextWidget = Text(
      '다음',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );

    void routeToRoleSelection() {
      // TODO: 역할 선택 화면 전환
    }

    void showExitDialog() {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text(
            '로그인 화면으로 돌아가시겠어요?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authUseCaseProvider).signOut();
              },
              child: const Text(
                '확인',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final bodyContent = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              '사용하실 닉네임을 입력해주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              height: 48,
              child: Placeholder(child: Center(child: Text('닉네임 입력 필드'))),
            ),
            const SizedBox(height: 4),
            Text(
              "10자 이내 한글·영문·숫자 사용가능\n띄어쓰기, 특수문자 사용 불가",
              style: TextStyle(
                fontSize: 12,
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: false,
      child: Platform.isIOS
          // iOS
          ? CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                automaticBackgroundVisibility: false,
                middle: titleTextWidget,
                leading: CupertinoNavigationBarBackButton(
                  previousPageTitle: '로그인',
                  onPressed: showExitDialog,
                ),
                trailing: CupertinoButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: routeToRoleSelection,
                  child: nextTextWidget,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: bodyContent,
              ),
            )
          // Android
          : Scaffold(
              appBar: AppBar(
                title: titleTextWidget,
                leading: BackButton(onPressed: showExitDialog),
                actions: [TextButton(onPressed: routeToRoleSelection, child: nextTextWidget)],
              ),
              body: bodyContent,
            ),
    );
  }
}
