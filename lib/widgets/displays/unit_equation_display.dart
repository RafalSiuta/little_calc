import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class UnitEquationDisplay extends StatelessWidget {
  const UnitEquationDisplay({Key? key, required this.equationDisplay, this.isActive = false}) : super(key: key);
  final String equationDisplay;
  final bool isActive;
  @override Widget build(BuildContext context) { final theme = context.calcTheme; return Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(border: isActive ? Border(bottom: BorderSide(color: theme.accent, width: theme.borderThickness)) : null), child: Text(equationDisplay, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: theme.displayMidTextStyle)); }
}
