import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/calculator_logic.dart';
import '../../providers/window_layout_provider.dart';
import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/styles/colors.dart';
import '../../widgets/displays/calculator_display.dart';
import '../../widgets/keyboards/calculator_keyboard.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({Key? key}) : super(key: key);

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  @override
  Widget build(BuildContext context) {
    final windowLayout = context.watch<WindowLayoutProvider>();

    return Consumer<CalculatorLogic>(
      builder: (context, data, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          // color: AppColors.background,
          child: Column(
            children: [
              Expanded(
                child: CalculatorDisplay(
                  data: data,
                  isExpanded: windowLayout.isExpanded,
                  onBackspace: data.delete,
                  onToggleCalculatorWidth: () {
                    windowLayout.toggleCalculatorWidth();
                  },
                ),
              ),
              const SizedBox(height: 16),
              CalculatorKeyboard(
                rows: windowLayout.isExpanded
                    ? CalcSymbols.expandedRows
                    : CalcSymbols.compactRows,
                onPressed: (value) {
                  final logicValue = CalcSymbols.logicValue(value);
                  if (logicValue.isEmpty) {
                    return;
                  }
                  data.multifunction(logicValue);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
