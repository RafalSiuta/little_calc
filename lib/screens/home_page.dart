import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../model/calculator_logic.dart';
import '../utils/styles/colors.dart';
import '../widgets/displays/calculator_display.dart';
import '../widgets/keyboards/calculator_keyboard.dart';
import '../widgets/options/calculator_options_bar.dart';
import '../widgets/window/window_title_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ColoredBox(
        color: AppColors.systemWindow,
        child: Column(
          children: [
            WindowTitleBar(),
            Expanded(child: CalculatorView()),
          ],
        ),
      ),
    );
  }
}

class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');
  static const int _compactWindowWidth = 390;
  static const int _expandedWindowWidth = 803;

  static const String _divisionSign = '\u00f7';
  static const String _multiplicationSign = '\u00d7';

  static const String _squareSign = 'x\u00b2';
  static const String _squareRootSign = '\u221a';

  static const List<List<String>> _compactRows = [
    ['C', '()', '%', _divisionSign],
    ['7', '8', '9', _multiplicationSign],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['+/-', '0', '.', '='],
  ];

  static const List<List<String>> _expandedRows = [
    [
      'sin',
      'cos',
      'Rad',
      _squareRootSign,
      _squareSign,
      'C',
      '()',
      '%',
      _divisionSign,
    ],
    [
      'sin\u207b\u00b9',
      'cos\u207b\u00b9',
      'tan\u207b\u00b9',
      '\u00b3\u221a',
      'x\u00b3',
      '7',
      '8',
      '9',
      _multiplicationSign,
    ],
    [
      'sinh',
      'cosh',
      'tanh',
      'y\u00b2',
      'e\u02e3',
      '4',
      '5',
      '6',
      '-',
    ],
    [
      'sinh\u207b\u00b9',
      'cosh\u207b\u00b9',
      'tanh\u207b\u00b9',
      '\u03c0',
      'e',
      '1',
      '2',
      '3',
      '+',
    ],
    ['ln', 'log', '1/x', '|x|', 'x!', '+/-', '0', '.', '='],
  ];

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
              CalculatorOptionsBar(
                onSettings: () => debugPrint('settings was pressed'),
                onToggleCalculatorWidth: _toggleCalculatorWidth,
              ),
              Expanded(
                child: CalculatorDisplay(
                  data: data,
                  onBackspace: data.delete,
                ),
              ),
              const SizedBox(height: 16),
              CalculatorKeyboard(
                rows: _isExpanded ? _expandedRows : _compactRows,
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
      case _divisionSign:
        return '/';
      case _multiplicationSign:
        return '*';
      case _squareRootSign:
        return 'sqrt';
      case _squareSign:
        return 'square';
      case '()':
        return '()';
      default:
        return value;
    }
  }
}
