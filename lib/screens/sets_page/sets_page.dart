import 'package:flutter/material.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../widgets/nav/calc_tab_bar/calc_tab_bar.dart';
import 'about_page.dart';
import 'language_page.dart';
import 'themes_page.dart';

class SetsPage extends StatelessWidget {
  const SetsPage({Key? key}) : super(key: key);

  static const List<String> _tabs = [
    'settings.themes',
    'settings.language',
    'settings.about',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalcTabBar(tabs: [for (final tab in _tabs) context.tr(tab)]),
          const Expanded(
            child: TabBarView(
              children: [ThemesPage(), LanguagePage(), AboutPage()],
            ),
          ),
        ],
      ),
    );
  }
}
