import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/domain/usecases/auth_use_case.dart';

class NicknameView extends ConsumerWidget {
  const NicknameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showExitDialog() {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(
            '로그인 화면으로 돌아갈까요?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authUseCaseProvider).signOut();
              },
              child: Text(
                '확인',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            title: Text(
              '닉네임 설정',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            leading: BackButton(
              onPressed: showExitDialog,
              color: Theme.of(context).colorScheme.primary,
            ),
            shape: Border(
              bottom: BorderSide(color: Color(0x4D000000), width: 0.33),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // TODO: 역할 선택 화면 전환
                },
                child: Text(
                  '다음',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  '사용하실 닉네임을 입력해주세요',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const SizedBox(
                  height: 48,
                  child: Placeholder(child: Center(child: Text('닉네임 입력 필드'))),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "10자 이내 한글·영문·숫자 사용가능\n띄어쓰기, 특수문자 사용 불가",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
