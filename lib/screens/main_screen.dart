import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/nav_model/nav_model.dart';
import '../models/screen_model/screen_model.dart';
import '../providers/calculator_memory_provider.dart';
import '../providers/theme_settings_provider.dart';
import '../providers/window_layout_provider.dart';
import '../utils/calc_logic/calculator_logic.dart';
import '../utils/calc_symbols/calc_symbols.dart';
import '../utils/extensions/color_formatter.dart';
import '../utils/internationalization/i18n_extension.dart';
import '../utils/styles/dimensions/dimensions.dart';
import '../utils/styles/theme.dart';
import '../utils/system/system_helper.dart';
import '../utils/unit_converter_logic/unit_converter_logic.dart';
import '../widgets/animations/display_motion.dart';
import '../widgets/keyboards/calculator_keyboard.dart';
import '../widgets/keyboards/scientific_calculator_keyboard.dart';
import '../widgets/options/calculator_options_bar.dart';
import '../widgets/window/window_title_bar.dart';
import 'calc_page/calc_page.dart';
import 'sets_page/sets_page.dart';
import 'unit_convert_page/unit_convert_page.dart';

enum _KeyboardLayout {
  hidden,
  compact,
  scientific,
  desktopConverter;

  double get height => this == hidden
      ? 0
      : AppDimens.calculatorKeyboardHeight(isExpanded: this == scientific);
}

// When restoring History, add HistoryPage with no shared keypad, like settings.
// When restoring Currencies, share the converter keypad layout with units.
// Show it only on the conversion tab when currencies are loaded. Route input
// through the shared memory handler to CurrenciesProvider.currencyLogic, and
// restore the saved tab and the keypad lock while the tab is changing.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition;
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;

  ScreenModel _requestedPage = ScreenModel.calculator;
  ScreenModel _currentPage = ScreenModel.calculator;
  ScreenModel? _outgoingPage;
  final Set<ScreenModel> _expandedMobilePages = {};
  bool _showHyperbolicFunctions = false;

  bool get _keyboardIsLocked => _outgoingPage != null;

  @override
  void initState() {
    super.initState();
    _transition = AnimationController(vsync: this, value: 1)
      ..addStatusListener(_finishTransition);
    _fadeIn = _transition.drive(CurveTween(curve: Curves.easeInOut));
    _fadeOut = ReverseAnimation(_fadeIn);
  }

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  void _onPageSelected(int index) {
    final page = ScreenModel.values[index];
    if (page == _requestedPage) return;

    if (_outgoingPage != null) {
      setState(() => _requestedPage = page);
      return;
    }

    _startTransition(page);
  }

  void _startTransition(ScreenModel page) {
    setState(() {
      _requestedPage = page;
      _outgoingPage = _currentPage;
      _currentPage = page;
    });
    _transition.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 225);
    _transition.forward(from: 0);
  }

  void _finishTransition(AnimationStatus status) {
    if (status != AnimationStatus.completed || _outgoingPage == null) return;

    if (_currentPage != _requestedPage) {
      _startTransition(_requestedPage);
      return;
    }

    setState(() => _outgoingPage = null);
  }

  bool _isExpanded(ScreenModel page, WindowLayoutProvider windowLayout) =>
      SystemHelper.isMobileSystem
      ? _expandedMobilePages.contains(page)
      : windowLayout.isExpanded;

  void _toggleLayout(ScreenModel page, WindowLayoutProvider windowLayout) {
    if (!SystemHelper.isMobileSystem) {
      windowLayout.toggleCalculatorWidth();
      return;
    }

    setState(() {
      if (!_expandedMobilePages.remove(page)) {
        _expandedMobilePages.add(page);
      }
    });
  }

  _KeyboardLayout _keyboardLayout(
    ScreenModel page,
    WindowLayoutProvider windowLayout,
  ) {
    final isExpanded = _isExpanded(page, windowLayout);
    return switch (page) {
      ScreenModel.calculator =>
        isExpanded ? _KeyboardLayout.scientific : _KeyboardLayout.compact,
      ScreenModel.units when !isExpanded => _KeyboardLayout.compact,
      ScreenModel.units =>
        SystemHelper.isMobileSystem
            ? _KeyboardLayout.hidden
            : _KeyboardLayout.desktopConverter,
      ScreenModel.settings => _KeyboardLayout.hidden,
    };
  }

  void _onKeyPressed(String label) {
    if (_keyboardIsLocked) return;

    if (label == CalcSymbols.trigToggleSign &&
        _currentPage == ScreenModel.calculator) {
      setState(() => _showHyperbolicFunctions = !_showHyperbolicFunctions);
      return;
    }

    final key = CalcSymbols.logicValue(label);
    if (key.isEmpty) return;

    switch (_currentPage) {
      case ScreenModel.calculator:
        final logic = context.read<CalculatorLogic>();
        _applyKey(
          key,
          logic.memoryValue,
          logic.recallMemoryValue,
          logic.multifunction,
        );
      case ScreenModel.units:
        final logic = context.read<UnitConverterLogic>();
        _applyKey(
          key,
          logic.memoryValue,
          logic.recallMemoryValue,
          logic.handleKeyPress,
        );
      case ScreenModel.settings:
        return;
    }
  }

  void _applyKey(
    String key,
    double? currentValue,
    ValueChanged<double> recall,
    ValueChanged<String> handleKey,
  ) {
    final handled = context.read<CalculatorMemoryProvider>().handleKey(
      key,
      currentValue: currentValue,
      onRecall: recall,
    );
    if (!handled) handleKey(key);
  }

  Widget _buildPage(
    ScreenModel page,
    WindowLayoutProvider windowLayout,
    _KeyboardLayout keyboard,
  ) {
    final isExpanded = _isExpanded(page, windowLayout);
    void toggleLayout() => _toggleLayout(page, windowLayout);

    final content = switch (page) {
      ScreenModel.calculator => Padding(
        padding: EdgeInsets.only(bottom: keyboard.height),
        child: CalcPage(isExpanded: isExpanded, onToggleLayout: toggleLayout),
      ),
      ScreenModel.units => UnitConvertPage(
        isExpanded: isExpanded,
        keyboardHeight: keyboard.height,
        onToggleLayout: toggleLayout,
      ),
      ScreenModel.settings => const SetsPage(),
    };
    final isOutgoing = page == _outgoingPage;
    final isTransitioning = _outgoingPage != null;
    final hasDisplays = keyboard != _KeyboardLayout.hidden;
    return FadeTransition(
      key: ValueKey(page),
      opacity: hasDisplays
          ? kAlwaysCompleteAnimation
          : isOutgoing
          ? _fadeOut
          : _fadeIn,
      child: ExcludeSemantics(
        excluding: isTransitioning,
        child: ExcludeFocus(
          excluding: isTransitioning,
          child: IgnorePointer(
            ignoring: isTransitioning,
            child: DisplayMotionScope(
              progress: _transition,
              isOutgoing: isOutgoing,
              enabled: hasDisplays,
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(_KeyboardLayout layout) {
    if (layout == _KeyboardLayout.hidden) return const SizedBox.shrink();

    final keyboard = layout == _KeyboardLayout.scientific
        ? ScientificCalculatorKeyboard(
            showHyperbolicFunctions: _showHyperbolicFunctions,
            onPressed: _onKeyPressed,
          )
        : CalculatorKeyboard(
            rows: CalcSymbols.compactRows,
            onPressed: _onKeyPressed,
          );
    return FractionallySizedBox(
      key: ValueKey(layout),
      alignment: Alignment.bottomRight,
      widthFactor: layout == _KeyboardLayout.desktopConverter ? 0.5 : 1,
      child: SizedBox(height: layout.height, child: keyboard),
    );
  }

  Widget _buildKeyboardTransition(
    _KeyboardLayout previous,
    _KeyboardLayout current,
  ) {
    final incoming = _buildKeyboard(current);
    final isChanging = _outgoingPage != null && previous != current;
    final outgoing = isChanging ? _buildKeyboard(previous) : null;
    return AnimatedBuilder(
      animation: _fadeIn,
      builder: (context, _) {
        final progress = _fadeIn.value;
        if (!isChanging) return Opacity(opacity: 1, child: incoming);
        if (previous == _KeyboardLayout.hidden) {
          return Opacity(opacity: progress, child: incoming);
        }
        if (current == _KeyboardLayout.hidden) {
          return Opacity(opacity: 1 - progress, child: outgoing);
        }
        return Opacity(
          opacity: (progress * 2 - 1).abs(),
          child: progress < 0.5 ? outgoing : incoming,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowLayout = context.watch<WindowLayoutProvider>();
    final themeSettings = context.watch<ThemeSettingsProvider>();
    final calcTheme = context.calcTheme;
    final outgoingPage = _outgoingPage;
    final keyboard = _keyboardLayout(_currentPage, windowLayout);
    final outgoingKeyboard = outgoingPage == null
        ? keyboard
        : _keyboardLayout(outgoingPage, windowLayout);
    final lockKeyboard = _keyboardIsLocked;

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
                for (final page in ScreenModel.values)
                  NavModel(
                    title: context.tr(page.nav.title),
                    icon: page.nav.icon,
                  ),
              ],
              selectedItem: _requestedPage.index,
              onItemSelected: _onPageSelected,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (outgoingPage != null)
                    _buildPage(outgoingPage, windowLayout, outgoingKeyboard),
                  _buildPage(_currentPage, windowLayout, keyboard),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ExcludeSemantics(
                      excluding: lockKeyboard,
                      child: ExcludeFocus(
                        excluding: lockKeyboard,
                        child: IgnorePointer(
                          ignoring: lockKeyboard,
                          child: _buildKeyboardTransition(
                            outgoingKeyboard,
                            keyboard,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
