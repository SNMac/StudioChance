import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/extensions/auth_exception_extension.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/components/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/sign_in/view_models/sign_in_view_model.dart';
import 'package:studio_chance/presentation/sign_in/views/components/social_sign_in_button.dart';

class SignInView extends ConsumerWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(signInViewModelProvider);
    final isLoading = asyncState.isLoading;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    void showErrorDialog(String title, String content) {
      showCustomAlertDialog(
        context: context,
        title: title,
        content: content,
        showCancel: false,
        onConfirm: () => Navigator.pop(context),
      );
    }

    void onGoogleButtonTapped() {
      ref.read(signInViewModelProvider.notifier).signInWithGoogle();
    }

    void onAppleButtonTapped() {
      ref.read(signInViewModelProvider.notifier).signInWithApple();
    }

    ref.listen(signInViewModelProvider, (previous, next) {
      next.when(
        data: (_) {},
        error: (error, stackTrace) {
          if (error is AuthException) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  if (isLoading)
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
