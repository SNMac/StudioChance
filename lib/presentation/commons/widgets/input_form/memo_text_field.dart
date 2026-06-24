import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class MemoTextField extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  /// 글자 수 카운터 표시. null이면 카운터 미표시.
  final int? maxLength;

  /// 표시할 최대 줄 수. 초과 시 TextField 내부 스크롤 활성화. null이면 무제한.
  final int? maxDisplayLines;

  const MemoTextField({
    super.key,
    required this.placeholder,
    required this.controller,
    this.onChanged,
    this.inputFormatters,
    this.autofocus = false,
    this.maxLength,
    this.maxDisplayLines = 10,
  });

  @override
  State<MemoTextField> createState() => _MemoTextFieldState();
}

class _MemoTextFieldState extends State<MemoTextField> {
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

    return Stack(
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          minLines: 3,
          maxLines: widget.maxDisplayLines,
          textAlignVertical: TextAlignVertical.top,
          cursorHeight: 20,
          autocorrect: true,
          enableSuggestions: true,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsetsDirectional.only(
              start: horizontalPadding,
              end: horizontalPadding,
              top: 12,
              // 카운터 표시 시 하단에 공간 확보
              bottom: widget.maxLength != null ? 32 : 12,
            ),
            hintText: widget.placeholder,
            hintStyle: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: context.tertiaryLabel,
            ),
          ),
        ),

        if (widget.maxLength != null)
          Positioned(
            bottom: 12,
            right: horizontalPadding,
            child: Text(
              '${widget.controller.text.length}/${widget.maxLength}',
              style: textTheme.labelLarge?.copyWith(
                color: context.secondaryLabel,
              ),
            ),
          ),
      ],
    );
  }
}
