import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitlePopupButton<T> extends StatefulWidget {
  final String title;
  final T selectedValue;
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String Function(T) itemLabelBuilder;
  final Widget Function(T)? itemLeadingBuilder;

  const TitlePopupButton({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
    required this.itemLabelBuilder,
    this.itemLeadingBuilder,
  });

  @override
  State<TitlePopupButton<T>> createState() => _TitlePopupButtonState<T>();
}

class _TitlePopupButtonState<T> extends State<TitlePopupButton<T>> {
  final GlobalKey<PopupMenuButtonState<T>> _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: CupertinoButton(
        padding: EdgeInsetsDirectional.zero,
        onPressed: () => _menuKey.currentState?.showButtonMenu(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.title, style: textTheme.bodyLarge),

            PopupMenuButton<T>(
              key: _menuKey,
              onSelected: widget.onSelected,
              color: context.tertiarySystemGroupedBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.itemLeadingBuilder != null) ...[
                    widget.itemLeadingBuilder!(widget.selectedValue),
                    const SizedBox(width: 8),
                  ],

                  Text(
                    widget.itemLabelBuilder(widget.selectedValue),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: context.secondaryLabel,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Icon(
                    CupertinoIcons.chevron_up_chevron_down,
                    size: 16,
                    color: context.secondaryLabel,
                  ),
                ],
              ),

              itemBuilder: (BuildContext context) {
                return widget.items.map((T item) {
                  final bool isSelected = item == widget.selectedValue;
                  return PopupMenuItem<T>(
                    value: item,
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            child: isSelected
                                ? const Icon(CupertinoIcons.checkmark, size: 16)
                                : null,
                          ),

                          if (widget.itemLeadingBuilder != null) ...[
                            widget.itemLeadingBuilder!(item),
                          ],

                          Text(
                            widget.itemLabelBuilder(item),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}
