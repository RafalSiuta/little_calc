import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/calc_logic/calculator_logic.dart';
import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/system/system_helper.dart';
import 'calculator_keyboard.dart';

class ScientificCalculatorKeyboard extends StatelessWidget {
  const ScientificCalculatorKeyboard({
    super.key,
    required this.showHyperbolicFunctions,
    required this.onPressed,
  });

  final bool showHyperbolicFunctions;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    final angleModeButtonLabel = context.select<CalculatorLogic, String>(
      (logic) => logic.angleModeButtonLabel,
    );
    final functionRows = showHyperbolicFunctions
        ? CalcSymbols.expandedHyperbolicFunctionRows
        : CalcSymbols.expandedFunctionRows;

    if (SystemHelper.isMobileSystem) {
      return SizedBox(
        height: AppDimens.calculatorKeyboardHeight(isExpanded: true),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: CalculatorKeyboard(
                rows: _rowsWithAngleMode(functionRows, angleModeButtonLabel),
                onPressed: onPressed,
                isExpandedLayout: true,
                isFunctionKeyboard: true,
              ),
            ),
            Expanded(
              flex: 4,
              child: CalculatorKeyboard(
                rows: CalcSymbols.expandedBasicRows,
                onPressed: onPressed,
                isExpandedLayout: true,
                rowOffset: functionRows.length,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: CalculatorKeyboard(
            rows: _rowsWithAngleMode(functionRows, angleModeButtonLabel),
            onPressed: onPressed,
            isFunctionKeyboard: true,
          ),
        ),
        Expanded(
          flex: 4,
          child: CalculatorKeyboard(
            rows: CalcSymbols.expandedBasicRows,
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }

  List<List<CalcKey>> _rowsWithAngleMode(
    List<List<CalcKey>> rows,
    String angleModeButtonLabel,
  ) {
    return rows
        .map(
          (row) => row
              .map(
                (value) => value.label == 'Rad' || value.label == 'Deg'
                    ? CalcKey(
                        angleModeButtonLabel,
                        type: value.type,
                        flex: value.flex,
                      )
                    : value,
              )
              .toList(),
        )
        .toList();
  }
}
