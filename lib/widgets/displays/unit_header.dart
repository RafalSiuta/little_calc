import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class UnitHeader extends StatelessWidget {
  const UnitHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: calcTheme.displayMidTextStyle.copyWith(
        color: calcTheme.text,
        fontWeight: FontWeight.w200,
      ),
    );
  }
}
