import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/calc_logic/calculator_logic.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../buttons/option_icon_button.dart';
import 'equation_display.dart';

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
    final calcTheme = context.calcTheme;
    final displayValue = data.display == 'Infinity' ? 'Error' : data.display;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        spacing: 16,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: data.equationDisplay.isEmpty
                        ? const SizedBox.shrink()
                        : EquationDisplay(
                            equation: data.equationDisplay,
                            onLongPress: () => _copyToClipboard(
                              context,
                              data.equationDisplay,
                            ),
                          ),
                  ),
                  // const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () => _copyToClipboard(
                          context,
                          displayValue,
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                calcTheme.accent,
                                calcTheme.accent2,
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              displayValue,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              style: calcTheme.displayLargeTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _InfoDisplay(
            infoMessage: data.valueDisplay,
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

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    if (value.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Skopiowano'),
          duration: Duration(milliseconds: 900),
        ),
      );
  }
}

class _InfoDisplay extends StatelessWidget {
  const _InfoDisplay({
    Key? key,
    required this.infoMessage,
    required this.errorMessage,
    required this.showError,
    required this.isExpanded,
    required this.onBackspace,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final String infoMessage;
  final String errorMessage;
  final bool showError;
  final bool isExpanded;
  final VoidCallback onBackspace;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage.isNotEmpty || showError;
    final hasInfo = !hasError && infoMessage.isNotEmpty;
    final calcTheme = context.calcTheme;
    final itemSpacing = AppDimens.currentItemSpacing();
    final message = errorMessage.isNotEmpty
        ? errorMessage
        : showError
            ? 'error - divide by 0'
            : infoMessage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: itemSpacing,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                if (hasError || hasInfo)
                  Icon(
                    hasError ? Icons.warning_amber : Icons.info_outline,
                    color: hasError ? calcTheme.error : calcTheme.accent,
                    size: 16,
                  ),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: calcTheme.displaySmallTextStyle.copyWith(
                      color: hasError ? calcTheme.error : calcTheme.accent,
                    ),
                  ),
                ),
              ],
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
    );
  }
}
