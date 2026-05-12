import 'package:flutter/material.dart';

import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/dimensions/font_sizes.dart';

class NumBtn extends StatefulWidget {
  const NumBtn({
    Key? key,
    required this.label,
    required this.onPressed,
    this.flex = 1,
    this.type = CalcKeyType.number,
  }) : super(key: key);

  final String label;
  final VoidCallback onPressed;
  final int flex;
  final CalcKeyType type;

  @override
  State<NumBtn> createState() => _NumBtnState();
}

class _NumBtnState extends State<NumBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: SizedBox(
        height: AppDimens.keyHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: AppDefaultColors.borderDark,
            highlightColor: AppDefaultColors.borderDark,
            hoverColor: AppDefaultColors.borderDark,
            onHighlightChanged: (isHighlighted) {
              setState(() => _isPressed = isHighlighted);
            },
            onTap: widget.onPressed,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(AppDimens.basePadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppDefaultColors.borderDark,
                  width: AppDimens.borderThickness,
                ),
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: _isPressed ? AppDefaultColors.accent : _textColor(),
                  fontFamily: 'Exo',
                  fontSize: AppFontSizes.buttonFontSize,
                  fontWeight: FontWeight.w100,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _textColor() {
    switch (widget.type) {
      case CalcKeyType.function:
        return AppDefaultColors.functionsText;
      case CalcKeyType.operator:
        return AppDefaultColors.operatorsText;
      case CalcKeyType.number:
        return AppDefaultColors.numbersText;
    }
  }
}
