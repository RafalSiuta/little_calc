import 'package:flutter/material.dart';

import '../buttons/numbtn.dart';

class CalculatorKeyboard extends StatelessWidget {
  const CalculatorKeyboard({
    Key? key,
    required this.rows,
    required this.onPressed,
  }) : super(key: key);

  final List<List<String>> rows;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final value in row)
                NumBtn(
                  label: value,
                  onPressed: () => onPressed(value),
                ),
            ],
          ),
      ],
    );
  }
}
