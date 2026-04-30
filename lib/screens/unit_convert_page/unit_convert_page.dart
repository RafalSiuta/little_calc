import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';

class UnitConvertPage extends StatelessWidget {
  const UnitConvertPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Konwerter jednostek');
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accent,
          fontFamily: 'Exo',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
