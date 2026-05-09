import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/dimensions/font_sizes.dart';

class NumBtn extends StatefulWidget {
  const NumBtn({
    Key? key,
    required this.label,
    required this.onPressed,
    this.flex = 1,
  }) : super(key: key);

  final String label;
  final VoidCallback onPressed;
  final int flex;

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
            splashColor: AppColors.borderDark,
            highlightColor: AppColors.borderDark,
            hoverColor: AppColors.borderDark,
            onHighlightChanged: (isHighlighted) {
              setState(() => _isPressed = isHighlighted);
            },
            onTap: widget.onPressed,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(AppDimens.basePadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderDark,
                  width: AppDimens.borderThickness,
                ),
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: _isPressed ? AppColors.accent : AppColors.text,
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
}
