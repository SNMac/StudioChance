import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 취소/확인 버튼이 있는 공용 다이얼로그 함수
Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  String cancelText = '취소',
  String confirmText = '확인',
  bool showCancel = true,
  bool isDestructive = false,
  VoidCallback? onConfirmBeforePop,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title, style: textTheme.titleLarge),
      content: content != null
          ? Text(content, style: textTheme.bodyMedium)
          : null,
      actions: [
        if (showCancel)
          if (Platform.isIOS)
            CupertinoButton(
              pressedOpacity: 1.0,
              padding: EdgeInsetsDirectional.all(0),
              onPressed: () => context.pop(),
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
              onPressed: () => context.pop(),
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
            onPressed: () {
              if (onConfirmBeforePop != null) onConfirmBeforePop();
              context.pop();
            },
            child: Text(
              confirmText,
              style: textTheme.titleLarge?.copyWith(
                color: isDestructive ? colorScheme.error : colorScheme.primary,
              ),
            ),
          )
        else
          TextButton(
            onPressed: () => onConfirmBeforePop,
            child: Text(
              confirmText,
              style: textTheme.titleLarge?.copyWith(
                color: isDestructive ? colorScheme.error : colorScheme.primary,
              ),
            ),
          ),
      ],
    ),
  );
}
