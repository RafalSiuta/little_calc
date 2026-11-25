import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/calc_symbols/calc_symbols.dart';
import '../animations/staggered_entrance.dart';
import '../buttons/numbtn.dart';

class CalculatorKeyboard extends StatelessWidget {
  const CalculatorKeyboard({
    Key? key,
    required this.rows,
    required this.onPressed,
    this.isExpandedLayout = false,
    this.isFunctionKeyboard = false,
    this.rowOffset = 0,
  }) : super(key: key);

  final List<List<CalcKey>> rows;
  final ValueChanged<String> onPressed;
  final bool isExpandedLayout;
  final bool isFunctionKeyboard;
  final int rowOffset;

  @override
  Widget build(BuildContext context) {
    final columnCount = rows.fold<int>(
      1,
      (count, row) =>
          math.max(count, row.fold<int>(0, (sum, key) => sum + key.flex)),
    );
    return Column(
      children: [
        for (final (index, row) in rows.indexed)
          _buildRow(row, (index + rowOffset) * columnCount, columnCount),
      ],
    );
  }

  Widget _buildRow(List<CalcKey> row, int position, int columnCount) {
    final buttons = <Widget>[];
    for (final key in row) {
      buttons.add(
        Expanded(
          flex: key.flex,
          child: StaggeredEntrance(
            position: position,
            columnCount: columnCount,
            child: NumBtn(
              label: key.label,
              type: key.type,
              onPressed: () => onPressed(key.label),
              isExpandedLayout: isExpandedLayout,
              isFunctionKeyboard: isFunctionKeyboard,
            ),
          ),
        ),
      );
      position += key.flex;
    }
    return Row(children: buttons);
  }
}
