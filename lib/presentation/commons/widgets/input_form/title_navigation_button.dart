import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleNavigationButton extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentLeading;

  /// content 오른쪽, chevron 앞에 표시할 위젯 (예: 대기 인원 배지).
  /// 길이가 고정적이라 content처럼 잘리지 않아야 하는 요소에 쓴다.
  final Widget? trailing;
  final bool isChangeable;
  final VoidCallback onPressed;

  const TitleNavigationButton({
    super.key,
    required this.title,
    this.content,
    this.contentLeading,
    this.trailing,
    this.isChangeable = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: CupertinoButton(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: horizontalPadding,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          // content가 길어 Expanded를 가득 채우면 title에 붙어버리므로
          // TitleTextLabel과 동일한 최소 간격을 둔다.
          spacing: 8,
          children: [
            Text(title, style: textTheme.bodyLarge),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (contentLeading != null) ...[
                    contentLeading!,
                    const SizedBox(width: 8),
                  ],

                  if (content != null)
                    Flexible(
                      child: Text(
                        content!,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: isChangeable
                              ? context.secondaryLabel
                              : context.label,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],

                  const SizedBox(width: 12),

                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 10),
                    child: Icon(
                      CupertinoIcons.chevron_forward,
                      color: context.tertiaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
