import 'package:flutter/material.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/theme.dart';

class AdvancedPage extends StatelessWidget {
  const AdvancedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsSubPagePlaceholder(title: context.tr('settings.advanced'));
  }
}

class _SettingsSubPagePlaceholder extends StatelessWidget {
  const _SettingsSubPagePlaceholder({Key? key, required this.title})
    : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(calcTheme.basePadding),
        child: Text(title, style: calcTheme.settingsTitleTextStyle),
      ),
    );
  }
}
