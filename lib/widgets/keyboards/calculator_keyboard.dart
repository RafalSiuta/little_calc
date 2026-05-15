import 'package:flutter/material.dart';

import '../../utils/calc_symbols/calc_symbols.dart';
import '../buttons/numbtn.dart';

class CalculatorKeyboard extends StatelessWidget {
  const CalculatorKeyboard({
    Key? key,
    required this.rows,
    required this.onPressed,
    this.isExpandedLayout = false,
  }) : super(key: key);

  final List<List<CalcKey>> rows;
  final ValueChanged<String> onPressed;
  final bool isExpandedLayout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final value in row)
                NumBtn(
                  label: value.label,
                  type: value.type,
                  onPressed: () => onPressed(value.label),
                  flex: value.flex,
                  isExpandedLayout: isExpandedLayout,
                ),
            ],
          ),
      ],
    );
  }
}
