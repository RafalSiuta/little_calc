import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/currency_model/currency.dart';
import '../../providers/currencies_provider.dart';
import '../../providers/window_layout_provider.dart';
import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/currency_logic/currency_logic.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../widgets/buttons/option_icon_button.dart';
import '../../widgets/cards/currency_card.dart';
import '../../widgets/displays/currency_choice_display.dart';
import '../../widgets/displays/currency_equation_display.dart';
import '../../widgets/keyboards/calculator_keyboard.dart';
import '../../widgets/nav/calc_tab_bar/calc_tab_bar.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({Key? key}) : super(key: key);

  static const List<String> _tabs = [
    'currencies',
    'raw materials',
    'crypto',
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
                _CurrenciesTab(),
                _PlaceholderPage(title: 'raw materials'),
                _PlaceholderPage(title: 'crypto'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrenciesTab extends StatelessWidget {
  const _CurrenciesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final windowLayout = context.watch<WindowLayoutProvider>();
    final provider = context.watch<CurrenciesProvider>();

    if (provider.isLoading && provider.currencies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.currencies.isEmpty) {
      return const _PlaceholderPage(title: 'currencies');
    }

    if (windowLayout.isExpanded) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _CurrenciesList()),
          Expanded(child: _CurrencyConverter()),
        ],
      );
    }

    return const _CurrencyConverter();
  }
}

class _CurrenciesList extends StatelessWidget {
  const _CurrenciesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final provider = context.watch<CurrenciesProvider>();

    return Column(
      children: [
        _CurrencyListHeader(
          onAddPressed: () {},
        ),
        SizedBox(height: calcTheme.itemSpacing),
        Expanded(
          child: ListView.separated(
            itemCount: provider.currencies.length,
            padding: EdgeInsets.all(calcTheme.basePadding),
            separatorBuilder: (context, index) => SizedBox(
              height: calcTheme.itemSpacing,
            ),
            itemBuilder: (context, index) {
              final currency = provider.currencies[index];

              return CurrencyCard(
                currency: currency,
                onTap: () => provider.setBaseCurrency(currency),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CurrencyListHeader extends StatelessWidget {
  const _CurrencyListHeader({
    Key? key,
    required this.onAddPressed,
  }) : super(key: key);

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final now = DateTime.now();
    final month = _monthName(now.month);
    final day = _weekdayName(now.weekday);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: calcTheme.basePadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${now.day} $month ${now.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: calcTheme.displayMidTextStyle.copyWith(
                    color: calcTheme.text,
                  ),
                ),
                Text(
                  day,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: calcTheme.displaySmallTextStyle.copyWith(
                    color: calcTheme.text,
                  ),
                ),
              ],
            ),
          ),
          OptionIconButton(
            icon: Icons.add,
            tooltip: 'Dodaj walute',
            isActive: false,
            usePressedAccent: true,
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}

class _CurrencyConverter extends StatelessWidget {
  const _CurrencyConverter({Key? key}) : super(key: key);

  void _handleKeyPress(CurrencyLogic logic, String value) {
    final logicValue = CalcSymbols.logicValue(value);
    if (logicValue.isEmpty) {
      return;
    }

    logic.handleKeyPress(logicValue);
  }

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final provider = context.watch<CurrenciesProvider>();
    final windowLayout = context.watch<WindowLayoutProvider>();
    final base = provider.baseCurrency ?? provider.currencies.first;
    final target = provider.targetCurrency ??
        (provider.currencies.length > 1 ? provider.currencies[1] : base);
    final logic = provider.currencyLogic;
    final resultCurrency = logic.resultCurrency ?? target;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(calcTheme.basePadding),
            child: _CurrencyDisplay(
              base: base,
              target: target,
              currencies: provider.currencies,
              baseValue: provider.formatCurrencyValue(logic.baseValueDisplay),
              targetValue:
                  provider.formatCurrencyValue(logic.targetValueDisplay),
              baseLabel: logic.baseLabel(base, target),
              targetLabel: logic.targetLabel(base, target),
              equationDisplay: logic.equationDisplay,
              resultDisplay: provider.formatCurrencyValue(logic.resultDisplay),
              resultCurrency: resultCurrency,
              rateDisplay: logic.rateDisplay(
                base,
                target,
                decimalPlaces: provider.currencyDecimalPlaces(),
              ),
              isExpanded: windowLayout.isExpanded,
              onBaseSelected: provider.setBaseCurrency,
              onTargetSelected: provider.setTargetCurrency,
              onSwapCurrencies: provider.swapCurrencies,
              onToggleCalculatorWidth: windowLayout.toggleCalculatorWidth,
              onBackspace: logic.delete,
            ),
          ),
        ),
        CalculatorKeyboard(
          rows: CalcSymbols.compactRows,
          onPressed: (value) => _handleKeyPress(logic, value),
        ),
      ],
    );
  }
}

class _CurrencyDisplay extends StatelessWidget {
  const _CurrencyDisplay({
    Key? key,
    required this.base,
    required this.target,
    required this.currencies,
    required this.baseValue,
    required this.targetValue,
    required this.baseLabel,
    required this.targetLabel,
    required this.equationDisplay,
    required this.resultDisplay,
    required this.resultCurrency,
    required this.rateDisplay,
    required this.isExpanded,
    required this.onBaseSelected,
    required this.onTargetSelected,
    required this.onSwapCurrencies,
    required this.onToggleCalculatorWidth,
    required this.onBackspace,
  }) : super(key: key);

  final Currency base;
  final Currency target;
  final List<Currency> currencies;
  final String baseValue;
  final String targetValue;
  final String baseLabel;
  final String targetLabel;
  final String equationDisplay;
  final String resultDisplay;
  final Currency resultCurrency;
  final String rateDisplay;
  final bool isExpanded;
  final ValueChanged<Currency> onBaseSelected;
  final ValueChanged<Currency> onTargetSelected;
  final VoidCallback onSwapCurrencies;
  final VoidCallback onToggleCalculatorWidth;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final activeDisplay = context.watch<CurrenciesProvider>().isActiveDisplay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CurrencyChoiceDisplay(
          currency: base,
          currencies: currencies,
          valueSymbol: _currencyGlyph(base),
          value: baseValue,
          label: baseLabel,
          isActive: activeDisplay == CurrencyActiveDisplay.base,
          onSelected: onBaseSelected,
        ),
        SizedBox(height: calcTheme.itemSpacing),
        CurrencyChoiceDisplay(
          currency: target,
          currencies: currencies,
          valueSymbol: _currencyGlyph(target),
          value: targetValue,
          label: targetLabel,
          isActive: activeDisplay == CurrencyActiveDisplay.target,
          onSelected: onTargetSelected,
        ),
        SizedBox(height: calcTheme.itemSpacing),
        CurrencyEquationDisplay(
          equationDisplay: equationDisplay,
          isActive: activeDisplay == CurrencyActiveDisplay.equation,
        ),
        Expanded(
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      calcTheme.accent,
                      calcTheme.accent2,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  _currencyGlyph(resultCurrency),
                  maxLines: 1,
                  style: calcTheme.displayLargeTextStyle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        calcTheme.accent,
                        calcTheme.accent2,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      resultDisplay,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: calcTheme.displayLargeTextStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _CurrencyInfoDisplay(
          rateDisplay: rateDisplay,
          isExpanded: isExpanded,
          onSwapCurrencies: onSwapCurrencies,
          onToggleCalculatorWidth: onToggleCalculatorWidth,
          onBackspace: onBackspace,
        ),
      ],
    );
  }
}

class _CurrencyInfoDisplay extends StatelessWidget {
  const _CurrencyInfoDisplay({
    Key? key,
    required this.rateDisplay,
    required this.isExpanded,
    required this.onSwapCurrencies,
    required this.onToggleCalculatorWidth,
    required this.onBackspace,
  }) : super(key: key);

  final String rateDisplay;
  final bool isExpanded;
  final VoidCallback onSwapCurrencies;
  final VoidCallback onToggleCalculatorWidth;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final itemSpacing = AppDimens.currentItemSpacing();

    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: itemSpacing,
            children: [
              Icon(
                Icons.info_outline,
                color: calcTheme.accent,
                size: 14,
              ),
              // SizedBox(width: itemSpacing),
              Expanded(
                child: Text(
                  rateDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: calcTheme.displaySmallTextStyle.copyWith(
                    color: calcTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          spacing: itemSpacing,
          children: [
            OptionIconButton(
              icon: Icons.autorenew,
              tooltip: 'Zamien waluty',
              isActive: false,
              usePressedAccent: true,
              onPressed: onSwapCurrencies,
            ),
            // SizedBox(width: itemSpacing),
            OptionIconButton(
              icon: isExpanded ? Icons.calculate_outlined : Icons.list,
              tooltip: isExpanded ? 'Zwin liste walut' : 'Pokaz liste walut',
              isActive: false,
              usePressedAccent: true,
              onPressed: onToggleCalculatorWidth,
            ),
            // SizedBox(width: itemSpacing),
            Consumer<CurrenciesProvider>(
              builder: (context, provider, child) {
                return OptionIconButton(
                  icon: Icons.arrow_upward,
                  tooltip: 'Poprzednia wartosc',
                  isActive: false,
                  usePressedAccent: true,
                  onPressed: () => provider.toggleActiveDisplay(next: false),
                );
              },
            ),
            // SizedBox(width: itemSpacing),
            Consumer<CurrenciesProvider>(
              builder: (context, provider, child) {
                return OptionIconButton(
                  icon: Icons.arrow_downward,
                  tooltip: 'Nastepna wartosc',
                  isActive: false,
                  usePressedAccent: true,
                  onPressed: () => provider.toggleActiveDisplay(next: true),
                );
              },
            ),
            // SizedBox(width: itemSpacing),
            OptionIconButton(
              icon: Icons.backspace_outlined,
              tooltip: 'Usun',
              isActive: false,
              usePressedAccent: true,
              onPressed: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        title,
        style: context.calcTheme.placeholderTextStyle,
      ),
    );
  }
}

String _currencyGlyph(Currency currency) {
  return currency.symbol;
}

String _monthName(int month) {
  const months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];

  return months[month - 1];
}

String _weekdayName(int weekday) {
  const days = [
    'poniedzialek',
    'wtorek',
    'sroda',
    'czwartek',
    'piatek',
    'sobota',
    'niedziela',
  ];

  return days[weekday - 1];
}
