import 'package:flutter/material.dart';

/// 취소/확인 버튼이 있는 공용 다이얼로그 함수
Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  String cancelText = '취소',
  String confirmText = '확인',
  bool showCancel = true,
  bool isDestructive = false,
  required VoidCallback onConfirm,
}) {
  return showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: content != null
          ? Text(
              content,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal),
            )
          : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
