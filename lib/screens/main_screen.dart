import 'package:bixcalc/screens/currency_page/currency_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nav_model/nav_model.dart';
import '../models/screen_model/screen_model.dart';
import '../providers/theme_settings_provider.dart';
import '../utils/custom_icons/bixcalc_icons.dart';
import '../utils/extensions/color_formatter.dart';
import '../utils/system/system_helper.dart';
import '../utils/styles/theme.dart';
import '../widgets/options/calculator_options_bar.dart';
import '../widgets/window/window_title_bar.dart';
import 'calc_page/calc_page.dart';
import 'sets_page/sets_page.dart';
import 'unit_convert_page/unit_convert_page.dart';

import '../utils/internationalization/i18n_extension.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<ScreenModel> _pages = const [
    ScreenModel(
      page: CalcPage(),
      nav: NavModel(
        title: 'navigation.calculator',
        icon: BixCalcIcons.calculator_simple,
      ),
    ),
    ScreenModel(
      page: UnitConvertPage(),
      nav: NavModel(
        title: 'navigation.units',
        icon: BixCalcIcons.ruler_triangle,
      ),
    ),
    ScreenModel(
      page: CurrencyPage(),
      nav: NavModel(
        title: 'waluty',
        icon: BixCalcIcons.sack_dollar,
      ),
    ),
    // ScreenModel(
    //   page: HistoryPage(),
    //   nav: NavModel(
    //     title: 'historia',
    //     icon: Icons.history,
    //   ),
    // ),
    ScreenModel(
      page: SetsPage(),
      nav: NavModel(title: 'navigation.settings', icon: BixCalcIcons.settings),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChange(int page) {
    if (page == _currentPage) {
      return;
    }

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSettingsProvider>(
      builder: (context, themeSettings, child) {
        final calcTheme = context.calcTheme;

        return Scaffold(
          backgroundColor: formatColorOpacity(
            calcTheme.background,
            themeSettings.backgroundOpacity,
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (!SystemHelper.isMobileSystem) const WindowTitleBar(),
                CalculatorOptionsBar(
                  items: [
                    for (final page in _pages)
                      NavModel(
                        title: context.tr(page.nav.title),
                        icon: page.nav.icon,
                      ),
                  ],
                  selectedItem: _currentPage,
                  onItemSelected: _onPageChange,
                ),
                Expanded(
                  child: PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _pages[index].page,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
