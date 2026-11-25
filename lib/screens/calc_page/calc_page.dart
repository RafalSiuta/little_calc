import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/calc_logic/calculator_logic.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/system/system_helper.dart';
import '../../widgets/animations/display_motion.dart';
import '../../widgets/displays/calculator_display.dart';

class CalcPage extends StatelessWidget {
  const CalcPage({
    super.key,
    required this.isExpanded,
    required this.onToggleLayout,
  });

  final bool isExpanded;
  final VoidCallback onToggleLayout;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CalculatorLogic>();
    final displaySpacing = isExpanded && !SystemHelper.isMobileSystem
        ? 0.0
        : AppDimens.itemSpacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: displaySpacing),
      child: DisplayMotion(
        child: CalculatorDisplay(
          data: data,
          isExpanded: isExpanded,
          onToggleCalculatorWidth: onToggleLayout,
        ),
      ),
    );
  }
}
