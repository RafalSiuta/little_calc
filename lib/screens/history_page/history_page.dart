import 'package:flutter/material.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(title: context.tr('pages.history'));
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(title, style: context.calcTheme.placeholderTextStyle),
    );
  }
}
