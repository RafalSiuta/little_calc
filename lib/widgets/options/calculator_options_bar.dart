import 'package:flutter/material.dart';

import '../../models/nav_model/nav_model.dart';
import '../../utils/styles/colors.dart';
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
    final leftItems =
        items.length > 1 ? items.take(items.length - 1).toList() : items;
    final rightItem = items.length > 1 ? items.last : null;

    return Container(
      height: 78,
      // margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.unselected,
            width: 0.5,
          ),
        ),
        // color: AppColors.background,
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leftItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = leftItems[index];
                return OptionIconButton(
                  icon: item.icon,
                  tooltip: item.title,
                  isActive: index == selectedItem,
                  onPressed: () => onItemSelected(index),
                );
              },
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
