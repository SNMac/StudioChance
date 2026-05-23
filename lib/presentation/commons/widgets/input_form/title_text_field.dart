import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleTextField extends StatelessWidget {
  final String title;
  final String? placeholder;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? returnButtonType;
  final bool autocorrect;

  const TitleTextField({
    super.key,
    required this.title,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.inputFormatters,
    this.keyboardType,
    this.returnButtonType,
    this.autocorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: horizontalPadding,
      ),
      child: SizedBox(
        height: inputFormComponentHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Text(title, style: textTheme.bodyLarge),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsetsDirectional.zero,
                  hintText: placeholder ?? title,
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: context.tertiaryLabel,
                  ),
                ),
                cursorHeight: 20,
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.end,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: returnButtonType,
                autofocus: autofocus,
                onChanged: onChanged,
                inputFormatters: inputFormatters,
                keyboardType: keyboardType,
                autocorrect: autocorrect,
                enableSuggestions: autocorrect,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
