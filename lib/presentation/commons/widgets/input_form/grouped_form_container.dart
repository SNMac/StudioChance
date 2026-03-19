import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class GroupedFormContainer extends StatelessWidget {
  final Widget? header;
  final Widget? footer;
  final List<Widget> children;

  const GroupedFormContainer({
    super.key,
    required this.children,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) header!,
        Container(
          decoration: BoxDecoration(
            color: context.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(formBorderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(formBorderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: context.separator,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}
