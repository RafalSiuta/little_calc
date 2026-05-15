import 'package:flutter/material.dart';

import '../../widgets/nav/calc_tab_bar/calc_tab_bar.dart';
import 'about_page.dart';
import 'advanced_page.dart';
import 'sets_currency_page.dart';
import 'themes_page.dart';

class SetsPage extends StatelessWidget {
  const SetsPage({Key? key}) : super(key: key);

  static const List<String> _tabs = [
    'themes',
    'advanced',
    'currency',
    'about',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalcTabBar(tabs: _tabs),
          Expanded(
            child: TabBarView(
              children: [
                ThemesPage(),
                AdvancedPage(),
                SetsCurrencyPage(),
                AboutPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
