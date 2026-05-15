import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(calcTheme.basePadding),
        child: Text(
          'about',
          style: calcTheme.settingsTitleTextStyle,
        ),
      ),
    );
  }
}
