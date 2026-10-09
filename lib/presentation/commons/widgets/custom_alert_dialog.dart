import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/presentation/commons/extensions/string_extension.dart';

/// 취소/확인 버튼이 있는 공용 다이얼로그 함수
///
/// 본문 일부를 강조해야 하면 [content] 대신 [contentSpans]를 넘긴다.
/// 각 조각의 style은 기본 본문 스타일 위에 덧씌워진다.
Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  List<TextSpan>? contentSpans,
  String cancelText = '취소',
  String confirmText = '확인',
  bool showCancel = true,
  bool isDestructive = false,
  VoidCallback? onConfirmBeforePop,
  VoidCallback? onConfirmAfterPop,
}) {
  assert(
    content == null || contentSpans == null,
    'content와 contentSpans는 함께 쓸 수 없다',
  );
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showAdaptiveDialog(
    context: context,
    builder: (dialogContext) {
      void onConfirmPressed() {
        if (onConfirmBeforePop != null) onConfirmBeforePop();
        dialogContext.pop();
        if (onConfirmAfterPop != null) onConfirmAfterPop();
      }

      return AlertDialog.adaptive(
        title: Text(title, style: textTheme.titleLarge),
        content: switch ((content, contentSpans)) {
          (final text?, _) => Text(
            text.insertZwj(),
            style: textTheme.labelLarge,
          ),
          (_, final spans?) => Text.rich(
            TextSpan(
              style: textTheme.labelLarge,
              children: [
                for (final span in spans)
                  TextSpan(text: span.text?.insertZwj(), style: span.style),
              ],
            ),
          ),
          _ => null,
        },
        actions: [
          if (showCancel)
            if (Platform.isIOS)
              CupertinoButton(
                pressedOpacity: 1.0,
                padding: const EdgeInsetsDirectional.all(0),
                onPressed: () => dialogContext.pop(),
                child: Text(
                  cancelText,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () => dialogContext.pop(),
                child: Text(
                  cancelText,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

          if (Platform.isIOS)
            CupertinoButton(
              pressedOpacity: 1.0,
              padding: const EdgeInsetsDirectional.all(0),
              onPressed: onConfirmPressed,
              child: Text(
                confirmText,
                style: textTheme.titleLarge?.copyWith(
                  color: isDestructive
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onConfirmPressed,
              child: Text(
                confirmText,
                style: textTheme.titleLarge?.copyWith(
                  color: isDestructive
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            ),
        ],
      );
    },
  );
}
