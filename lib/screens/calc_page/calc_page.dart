import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/calculator_logic.dart';
import '../../utils/calc_symbols/calc_symbole.dart';
import '../../utils/styles/colors.dart';
import '../../widgets/displays/calculator_display.dart';
import '../../widgets/keyboards/calculator_keyboard.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({Key? key}) : super(key: key);

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');
  static const int _compactWindowWidth = 390;
  static const int _expandedWindowWidth = 803;

  bool _isExpanded = false;

  Future<void> _toggleCalculatorWidth() async {
    final nextIsExpanded = !_isExpanded;
    final nextWidth =
        nextIsExpanded ? _expandedWindowWidth : _compactWindowWidth;

    try {
      await _windowChannel.invokeMethod<void>(
        'setCalculatorWidth',
        {'width': nextWidth},
      );
      if (!mounted) {
        return;
      }
      setState(() => _isExpanded = nextIsExpanded);
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      setState(() => _isExpanded = nextIsExpanded);
    } on PlatformException {
      // Keep the current visual state if the native runner rejects the resize.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorLogic>(
      builder: (context, data, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.background,
          child: Column(
            children: [
              Expanded(
                child: CalculatorDisplay(
                  data: data,
                  isExpanded: _isExpanded,
                  onBackspace: data.delete,
                  onToggleCalculatorWidth: _toggleCalculatorWidth,
                ),
              ),
              const SizedBox(height: 16),
              CalculatorKeyboard(
                rows: _isExpanded
                    ? CalcSymbols.expandedRows
                    : CalcSymbols.compactRows,
                onPressed: (value) {
                  final logicValue = _logicValue(value);
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

  String _logicValue(String value) {
    switch (value) {
      case CalcSymbols.divisionSign:
        return '/';
      case CalcSymbols.multiplicationSign:
        return '*';
      case CalcSymbols.squareRootSign:
        return 'sqrt';
      case CalcSymbols.squareSign:
        return 'square';
      case '()':
        return '()';
      default:
        return value;
    }
  }
}
