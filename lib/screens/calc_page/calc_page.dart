import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/calc_logic/calculator_logic.dart';
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
          // color: AppDefaultColors.background,
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
                angleModeButtonLabel: data.angleModeButtonLabel,
                onPressed: data.multifunction,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalculatorKeyboards extends StatefulWidget {
  const _CalculatorKeyboards({
    Key? key,
    required this.isExpanded,
    required this.angleModeButtonLabel,
    required this.onPressed,
  }) : super(key: key);

  final bool isExpanded;
  final String angleModeButtonLabel;
  final ValueChanged<String> onPressed;

  @override
  State<_CalculatorKeyboards> createState() => _CalculatorKeyboardsState();
}

class _CalculatorKeyboardsState extends State<_CalculatorKeyboards> {
  bool _showHyperbolicFunctions = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return CalculatorKeyboard(
        rows: CalcSymbols.compactRows,
        onPressed: _handleKeyPress,
      );
    }

    final functionRows = _showHyperbolicFunctions
        ? CalcSymbols.expandedHyperbolicFunctionRows
        : CalcSymbols.expandedFunctionRows;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: CalculatorKeyboard(
            rows: _rowsWithAngleMode(functionRows),
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
    if (value == CalcSymbols.trigToggleSign) {
      setState(() => _showHyperbolicFunctions = !_showHyperbolicFunctions);
      return;
    }

    final logicValue = CalcSymbols.logicValue(value);
    if (logicValue.isEmpty) {
      return;
    }
    widget.onPressed(logicValue);
  }

  List<List<CalcKey>> _rowsWithAngleMode(List<List<CalcKey>> rows) {
    return rows
        .map(
          (row) => row
              .map((value) => value.label == 'Rad' || value.label == 'Deg'
                  ? CalcKey(
                      widget.angleModeButtonLabel,
                      type: value.type,
                      flex: value.flex,
                    )
                  : value)
              .toList(),
        )
        .toList();
  }
}
