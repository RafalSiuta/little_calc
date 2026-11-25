import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/calc_logic/calculator_logic.dart';
import '../../utils/custom_icons/bixcalc_icons.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../animations/calculation_completion.dart';
import '../buttons/option_icon_button.dart';
import 'equation_display.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    Key? key,
    required this.data,
    required this.isExpanded,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final CalculatorLogic data;
  final bool isExpanded;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final showDivisionError =
        data.display == 'Infinity' || data.display == '-Infinity';
    final displayValue = showDivisionError
        ? context.tr('errors.generic')
        : data.display;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.basePadding),
      child: Column(
        spacing: AppDimens.displayInfoSpacing,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EquationAfterEquals(
                  equation: data.equationDisplay,
                  completedCalculations: data.completedCalculations,
                  flexible: true,
                  builder: (equation) => equation.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimens.itemSpacing,
                          ),
                          child: EquationDisplay(
                            equation: equation,
                            onLongPress: () =>
                                _copyToClipboard(context, equation),
                          ),
                        ),
                ),
                Flexible(
                  child: ResultAfterEquals(
                    completedCalculations: data.completedCalculations,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () =>
                          _copyToClipboard(context, displayValue),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [calcTheme.accent, calcTheme.accent2],
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
                            style: calcTheme.displayLargeTextStyle.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _InfoDisplay(
            infoMessage: data.valueDisplay,
            error: data.error,
            showDivisionError: showDivisionError,
            isExpanded: isExpanded,
            onToggleCalculatorWidth: onToggleCalculatorWidth,
          ),
        ],
      ),
    );
  }

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
        SnackBar(
          content: Text(context.tr('actions.copied')),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }
}

class _InfoDisplay extends StatelessWidget {
  const _InfoDisplay({
    Key? key,
    required this.infoMessage,
    required this.error,
    required this.showDivisionError,
    required this.isExpanded,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final String infoMessage;
  final CalculatorError? error;
  final bool showDivisionError;
  final bool isExpanded;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null || showDivisionError;
    final hasInfo = !hasError && infoMessage.isNotEmpty;
    final calcTheme = context.calcTheme;
    final itemSpacing = AppDimens.currentItemSpacing();
    final message = switch (error) {
      final error? => context.tr('errors.${error.name}'),
      null when showDivisionError => context.tr('errors.divide_by_zero'),
      null => infoMessage,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingSmall),
      child: Row(
        spacing: itemSpacing,
        children: [
          Expanded(
            child: Row(
              spacing: itemSpacing,
              children: [
                if (hasError || hasInfo)
                  Icon(
                    hasError
                        ? BixCalcIcons.warning_amber
                        : BixCalcIcons.square_info,
                    color: hasError ? calcTheme.error : calcTheme.accent,
                    size: AppDimens.smallIconSize,
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
            size: isExpanded
                ? const Size.square(AppDimens.baseIconSize)
                : const Size(
                    AppDimens.expandCalculatorIconWidth,
                    AppDimens.baseIconSize,
                  ),
            icon: isExpanded
                ? BixCalcIcons.calculator_simple
                : BixCalcIcons.calc_extend,
            tooltip: isExpanded
                ? context.tr('actions.collapse_calculator')
                : context.tr('actions.expand_calculator'),
            isActive: false,
            usePressedAccent: true,
            onPressed: onToggleCalculatorWidth,
          ),
        ],
      ),
    );
  }
}
