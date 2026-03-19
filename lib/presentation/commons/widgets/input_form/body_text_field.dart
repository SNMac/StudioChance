import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class BodyTextField extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool autofocus;
  final bool showClearButton;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? returnButtonType;
  final bool autocorrect;

  const BodyTextField({
    super.key,
    required this.placeholder,
    required this.controller,
    this.onChanged,
    required this.maxLines,
    this.autofocus = false,
    this.showClearButton = false,
    this.inputFormatters,
    this.keyboardType,
    this.returnButtonType,
    this.autocorrect = false,
  });

  @override
  State<BodyTextField> createState() => _BodyTextFieldState();
}

class _BodyTextFieldState extends State<BodyTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(_updateState);
    widget.controller.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateState);
    widget.controller.removeListener(_updateState);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final bool isVisible =
        widget.showClearButton &&
        _focusNode.hasFocus &&
        widget.controller.text.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: inputFormComponentHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CupertinoTextField.borderless(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: horizontalPadding,
              ),
              placeholder: widget.placeholder,
              placeholderStyle: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: context.tertiaryLabel,
              ),
              textInputAction: widget.returnButtonType,
              cursorHeight: 20,
              controller: widget.controller,
              focusNode: _focusNode,
              textAlignVertical: TextAlignVertical.center,
              maxLines: widget.maxLines,
              autofocus: widget.autofocus,
              clearButtonMode: OverlayVisibilityMode.never,
              onChanged: widget.onChanged,
              inputFormatters: widget.inputFormatters,
              keyboardType: widget.keyboardType,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.autocorrect,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          if (isVisible)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: horizontalPadding),
              child: SizedBox(
                width: 20,
                child: CupertinoButton(
                  padding: EdgeInsetsDirectional.zero,
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: context.tertiaryLabel,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
