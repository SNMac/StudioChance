import 'package:flutter/material.dart';

/// 취소/확인 버튼이 있는 공용 다이얼로그 함수
Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  String cancelText = '취소',
  String confirmText = '확인',
  required VoidCallback onConfirm,
}) {
  return showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
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
        // 확인 버튼
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
