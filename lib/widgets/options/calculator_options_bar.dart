import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';

class CalculatorOptionsBar extends StatelessWidget {
  const CalculatorOptionsBar({
    Key? key,
    required this.onBackspace,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final VoidCallback onBackspace;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.unselected,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const _OptionIcon(icon: Icons.history),
                const SizedBox(width: 16),
                const _OptionIcon(icon: Icons.attach_money),
                const SizedBox(width: 16),
                const _OptionIcon(icon: Icons.straighten),
                const SizedBox(width: 16),
                _OptionIcon(
                  icon: Icons.calculate_outlined,
                  onPressed: onToggleCalculatorWidth,
                ),
              ],
            ),
          ),
          IconButton(
            splashColor: AppColors.borderDark,
            highlightColor: AppColors.borderDark,
            hoverColor: AppColors.borderDark,
            onPressed: onBackspace,
            icon: const Icon(
              Icons.backspace_outlined,
              color: AppColors.unselected,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionIcon extends StatelessWidget {
  const _OptionIcon({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppColors.borderDark,
          highlightColor: AppColors.borderDark,
          hoverColor: AppColors.borderDark,
          onTap: onPressed,
          child: Icon(
            icon,
            color: AppColors.unselected,
            size: 24,
          ),
        ),
      ),
    );
  }
}
