import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/dimensions/font_sizes.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Konwerter walut');
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: AppColors.background,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accent,
          fontFamily: 'Exo',
          fontSize: AppFontSizes.displayMidFontSize,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
