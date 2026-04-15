import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';

class NumBtn extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: 58,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: AppColors.borderDark,
            highlightColor: AppColors.borderDark,
            hoverColor: AppColors.borderDark,
            onTap: onPressed,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderDark,
                  width: 0.3,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontFamily: 'Exo',
                  fontSize: 24,
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
