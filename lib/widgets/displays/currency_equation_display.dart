import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class CurrencyEquationDisplay extends StatelessWidget {
  const CurrencyEquationDisplay({
    Key? key,
    required this.equationDisplay,
    this.isActive = false,
  }) : super(key: key);

  final String equationDisplay;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isActive
            ? Border(
                bottom: BorderSide(
                  color: calcTheme.accent,
                  width: calcTheme.borderThickness,
                ),
              )
            : null,
      ),
      child: Text(
        equationDisplay,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: calcTheme.displayMidTextStyle,
      ),
    );
  }
}
