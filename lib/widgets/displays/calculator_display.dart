import 'package:flutter/material.dart';

import '../../model/calculator_logic.dart';
import '../../utils/styles/colors.dart';
import '../buttons/option_icon_button.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    Key? key,
    required this.data,
    required this.isExpanded,
    required this.onBackspace,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final CalculatorLogic data;
  final bool isExpanded;
  final VoidCallback onBackspace;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    // data.equationDisplay = _equationText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (data.equationDisplay.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          data.equationDisplay,
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
          _InfoDisplay(
            errorMessage: data.errorMessage,
            showError: data.display == 'Infinity',
            isExpanded: isExpanded,
            onBackspace: onBackspace,
            onToggleCalculatorWidth: onToggleCalculatorWidth,
          ),
        ],
      ),
    );
  }

  // String _equationText() {
  //   if (data.operator.isEmpty) {
  //     return '';
  //   }
  //   final leftSide = data.oldText.isNotEmpty ? data.oldText : data.display;
  //   return '$leftSide ${_operatorGlyph(data.operator)}';
  // }

  // String _operatorGlyph(String value) {
  //   switch (value) {
  //     case '/':
  //       return '\u00f7';
  //     case '*':
  //       return '\u00d7';
  //     default:
  //       return value;
  //   }
  // }
}

class _InfoDisplay extends StatelessWidget {
  const _InfoDisplay({
    Key? key,
    required this.errorMessage,
    required this.showError,
    required this.isExpanded,
    required this.onBackspace,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final String errorMessage;
  final bool showError;
  final bool isExpanded;
  final VoidCallback onBackspace;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : showError
                        ? 'error - divide by 0'
                        : '',
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

            OptionIconButton(
              icon: isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
              tooltip: isExpanded ? 'Zwez kalkulator' : 'Rozszerz kalkulator',
              isActive: false,
              usePressedAccent: true,
              onPressed: onToggleCalculatorWidth,
            ),
            // const SizedBox(width: 16),
            OptionIconButton(
              icon: Icons.backspace_outlined,
              tooltip: 'Usun',
              isActive: false,
              usePressedAccent: true,
              onPressed: onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}
