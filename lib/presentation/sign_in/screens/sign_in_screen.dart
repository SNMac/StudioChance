import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/sign_in/controllers/sign_in_controller.dart';
import 'package:studio_chance/presentation/sign_in/widgets/social_sign_in_button.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);

    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    void showErrorDialog(String title, String content) {
      showCustomAlertDialog(
        context: context,
        title: title,
        content: content,
        showCancel: false,
        onConfirm: () => context.pop(),
      );
    }

    void onGoogleButtonTapped() {
      ref.read(signInControllerProvider.notifier).signInWithGoogle();
    }

    void onAppleButtonTapped() {
      ref.read(signInControllerProvider.notifier).signInWithApple();
    }

    ref.listen(signInControllerProvider, (previous, next) {
      next.when(
        data: (_) {},
        error: (error, stackTrace) {
          if (error is AppException) {
            showErrorDialog(error.title, error.content);
          } else {
            showErrorDialog('오류 발생', '개발자에게 문의해주세요.\n(${error.toString()})');
          }
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        CupertinoColors.systemBackground,
        context,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                const SizedBox(width: 180, height: 180, child: Placeholder()),
                Text(
                  'Studio Chance',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),

            const Spacer(flex: 2),

            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  if (state.isLoading)
                    const SizedBox(
                      height: 108,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else ...[
                    // Google 로그인 버튼
                    SocialSignInButton(
                      onPressed: onGoogleButtonTapped,
                      iconPath: 'assets/images/logos/google_logo.svg',
                      label: 'Google로 로그인',
                      fontFamily: 'Roboto',
                      backgroundColor: isDarkMode
                          ? googleSignInBackgroundDarkColor
                          : googleSignInBackgroundColor,
                      textColor: isDarkMode
                          ? googleSignInTextDarkColor
                          : googleSignInTextColor,
                      borderColor: isDarkMode
                          ? googleSignInBorderDarkColor
                          : googleSignInBorderColor,
                    ),

                    // Apple 로그인 버튼
                    SocialSignInButton(
                      onPressed: onAppleButtonTapped,
                      iconPath: 'assets/images/logos/apple_logo.svg',
                      label: 'Apple로 로그인',
                      backgroundColor: isDarkMode
                          ? appleSignInBackgroundDarkColor
                          : appleSignInBackgroundColor,
                      textColor: isDarkMode
                          ? appleSignInTextDarkColor
                          : appleSignInTextColor,
                      logoColor: isDarkMode
                          ? appleSignInTextDarkColor
                          : appleSignInTextColor,
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
