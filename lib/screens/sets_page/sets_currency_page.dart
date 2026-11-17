import 'package:flutter/material.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/theme.dart';

class SetsCurrencyPage extends StatelessWidget {
  const SetsCurrencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(calcTheme.basePadding),
        child: Text(
          context.tr('settings.currency'),
          style: calcTheme.settingsTitleTextStyle,
        ),
      ),
    );
  }
}
