import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleNavigationButton extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentLeading;
  final VoidCallback onPressed;

  const TitleNavigationButton({
    super.key,
    required this.title,
    this.content,
    this.contentLeading,
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
                          color: context.secondaryLabel,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

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
