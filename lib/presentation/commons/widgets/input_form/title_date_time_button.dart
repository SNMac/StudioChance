import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleDateTimeButton extends StatelessWidget {
  final String title;
  final String content;
  final bool isOpen;
  final VoidCallback onPressed;

  final CupertinoDatePickerMode mode;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  final bool use24hFormat;

  const TitleDateTimeButton({
    super.key,
    required this.title,
    required this.content,
    required this.isOpen,
    required this.onPressed,
    required this.initialDateTime,
    required this.onDateTimeChanged,
    this.mode = CupertinoDatePickerMode.time,
    this.use24hFormat = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const double pickerHeight = 200.0;
    const double dividerHeight = 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: inputFormComponentHeight,
          child: CupertinoButton(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onPressed();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Text(title, style: textTheme.bodyLarge),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.tertiarySystemFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    content,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: isOpen ? context.systemBlue : context.label,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isOpen ? (pickerHeight + dividerHeight) : 0,

            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Divider(
                    height: dividerHeight,
                    thickness: 0.5,
                    color: context.separator,
                  ),

                  SizedBox(
                    height: pickerHeight,
                    child: CupertinoDatePicker(
                      // mode별로 서로 다른 내부 State 클래스를 사용하므로(Flutter 프레임워크
                      // 제약), mode가 바뀔 때 key도 함께 바뀌어야 기존 State를 재사용하지
                      // 않고 새로 mount된다. 그렇지 않으면 "mode cannot change once it's
                      // built" 어설션이 발생한다.
                      key: ValueKey(mode),
                      mode: mode,
                      initialDateTime: initialDateTime,
                      use24hFormat: use24hFormat,
                      onDateTimeChanged: onDateTimeChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
