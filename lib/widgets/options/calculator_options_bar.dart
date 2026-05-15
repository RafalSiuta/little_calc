import 'package:flutter/material.dart';

import '../../models/nav_model/nav_model.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../buttons/option_icon_button.dart';

class CalculatorOptionsBar extends StatelessWidget {
  const CalculatorOptionsBar({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  final List<NavModel> items;
  final int selectedItem;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final itemSpacing = AppDimens.currentItemSpacing();
    final leftItems =
        items.length > 1 ? items.take(items.length - 1).toList() : items;
    final rightItem = items.length > 1 ? items.last : null;

    return Container(
      height: AppDimens.calculatorOptionsBarHeight(),
      // margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: calcTheme.unselected,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: itemSpacing,
              children: [
                for (var index = 0; index < leftItems.length; index++)
                  OptionIconButton(
                    icon: leftItems[index].icon,
                    tooltip: leftItems[index].title,
                    isActive: index == selectedItem,
                    onPressed: () => onItemSelected(index),
                  ),
              ],
            ),
          ),
          if (rightItem != null)
            OptionIconButton(
              icon: rightItem.icon,
              tooltip: rightItem.title,
              isActive: selectedItem == items.length - 1,
              onPressed: () => onItemSelected(items.length - 1),
            ),
        ],
      ),
    );
  }
}
