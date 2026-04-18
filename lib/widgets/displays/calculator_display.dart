import 'package:flutter/material.dart';

import '../../model/calculator_logic.dart';
import '../../utils/styles/colors.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({Key? key, required this.data}) : super(key: key);

  final CalculatorLogic data;

  @override
  Widget build(BuildContext context) {
    final equation = _equationText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _InfoDisplay(showError: data.display == 'Infinity'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (equation.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          equation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontFamily: 'Exo',
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          data.display,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontFamily: 'Exo',
                            fontSize: 48,
                            fontWeight: FontWeight.w200,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _equationText() {
    if (data.operator.isEmpty) {
      return '';
    }
    final leftSide = data.oldText.isNotEmpty ? data.oldText : data.display;
    return '$leftSide ${_operatorGlyph(data.operator)}';
  }

  String _operatorGlyph(String value) {
    switch (value) {
      case '/':
        return '\u00f7';
      case '*':
        return '\u00d7';
      default:
        return value;
    }
  }
}

class _InfoDisplay extends StatelessWidget {
  const _InfoDisplay({Key? key, required this.showError}) : super(key: key);

  final bool showError;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                showError ? 'error - divide by 0' : '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.error,
                  fontFamily: 'Exo',
                  fontSize: 10,
                  fontWeight: FontWeight.w200,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
            const Icon(
              Icons.settings_outlined,
              color: AppColors.unselected,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
