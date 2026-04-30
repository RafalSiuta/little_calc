import 'package:flutter/material.dart';

import '../models/nav_model/nav_model.dart';
import '../models/screen_model/screen_model.dart';
import '../utils/styles/colors.dart';
import '../widgets/options/calculator_options_bar.dart';
import '../widgets/window/window_title_bar.dart';
import 'calc_page/calc_page.dart';
import 'currency_page/currency_page.dart';
import 'history_page/history_page.dart';
import 'sets_page/sets_page.dart';
import 'unit_convert_page/unit_convert_page.dart';

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
        title: 'kalkulator',
        icon: Icons.calculate_outlined,
      ),
    ),
    ScreenModel(
      page: CurrencyPage(),
      nav: NavModel(
        title: 'waluty',
        icon: Icons.attach_money,
      ),
    ),
    ScreenModel(
      page: UnitConvertPage(),
      nav: NavModel(
        title: 'jednostki',
        icon: Icons.straighten,
      ),
    ),
    ScreenModel(
      page: HistoryPage(),
      nav: NavModel(
        title: 'historia',
        icon: Icons.history,
      ),
    ),
    ScreenModel(
      page: SetsPage(),
      nav: NavModel(
        title: 'ustawienia',
        icon: Icons.settings_outlined,
      ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ColoredBox(
        color: AppColors.systemWindow,
        child: Column(
          children: [
            const WindowTitleBar(),
            CalculatorOptionsBar(
              items: _pages.map((page) => page.nav).toList(),
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
  }
}
