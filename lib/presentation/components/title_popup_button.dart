import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitlePopupButton<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: textTheme.bodyLarge),
          PopupMenuButton<T>(
            onSelected: onSelected,
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.tertiarySystemGroupedBackground,
              context,
            ),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (itemLeadingBuilder != null) ...[
                  itemLeadingBuilder!(selectedValue),
                  const SizedBox(width: 8),
                ],

                Text(
                  itemLabelBuilder(selectedValue),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                Icon(
                  CupertinoIcons.chevron_up_chevron_down,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel,
                    context,
                  ),
                ),
              ],
            ),

            itemBuilder: (BuildContext context) {
              return items.map((T item) {
                final bool isSelected = item == selectedValue;
                return PopupMenuItem<T>(
                  value: item,
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        isSelected
                            ? const Icon(CupertinoIcons.check_mark, size: 16)
                            : const SizedBox(width: 16),

                        if (itemLeadingBuilder != null) ...[
                          itemLeadingBuilder!(item),
                        ],

                        Text(
                          itemLabelBuilder(item),
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
    );
  }
}
