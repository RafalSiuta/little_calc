import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/calculator_logic.dart';
import '../../providers/window_layout_provider.dart';
import '../../utils/calc_symbols/calc_symbols.dart';
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
        return SizedBox(
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
              _CalculatorKeyboards(
                isExpanded: windowLayout.isExpanded,
                onPressed: data.multifunction,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalculatorKeyboards extends StatelessWidget {
  const _CalculatorKeyboards({
    Key? key,
    required this.isExpanded,
    required this.onPressed,
  }) : super(key: key);

  final bool isExpanded;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) {
      return CalculatorKeyboard(
        rows: CalcSymbols.compactRows,
        onPressed: _handleKeyPress,
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: CalculatorKeyboard(
            rows: CalcSymbols.expandedFunctionRows,
            onPressed: _handleKeyPress,
          ),
        ),
        Expanded(
          flex: 4,
          child: CalculatorKeyboard(
            rows: CalcSymbols.expandedBasicRows,
            onPressed: _handleKeyPress,
          ),
        ),
      ],
    );
  }

  void _handleKeyPress(String value) {
    final logicValue = CalcSymbols.logicValue(value);
    if (logicValue.isEmpty) {
      return;
    }
    onPressed(logicValue);
  }
}
