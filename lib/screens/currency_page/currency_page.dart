import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/currency_model/currency.dart';
import '../../providers/currencies_provider.dart';
import '../../providers/window_layout_provider.dart';
import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../widgets/buttons/option_icon_button.dart';
import '../../widgets/cards/currency_card.dart';
import '../../widgets/displays/currency_choice_display.dart';
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final provider = context.watch<CurrenciesProvider>();
    final windowLayout = context.watch<WindowLayoutProvider>();
    final base = provider.baseCurrency ?? provider.currencies.first;
    final target = provider.targetCurrency ??
        (provider.currencies.length > 1 ? provider.currencies[1] : base);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(calcTheme.basePadding),
            child: _CurrencyDisplay(
              base: base,
              target: target,
              currencies: provider.currencies,
              isExpanded: windowLayout.isExpanded,
              onBaseSelected: provider.setBaseCurrency,
              onTargetSelected: provider.setTargetCurrency,
              onToggleCalculatorWidth: windowLayout.toggleCalculatorWidth,
            ),
          ),
        ),
        CalculatorKeyboard(
          rows: CalcSymbols.compactRows,
          onPressed: (_) {},
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
    required this.isExpanded,
    required this.onBaseSelected,
    required this.onTargetSelected,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final Currency base;
  final Currency target;
  final List<Currency> currencies;
  final bool isExpanded;
  final ValueChanged<Currency> onBaseSelected;
  final ValueChanged<Currency> onTargetSelected;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CurrencyChoiceDisplay(
          currency: base,
          currencies: currencies,
          valueSymbol: _currencyGlyph(base),
          value: '1078.34',
          label: 'from: ${base.valueName}',
          isActive: true,
          onSelected: onBaseSelected,
        ),
        SizedBox(height: calcTheme.itemSpacing),
        CurrencyChoiceDisplay(
          currency: target,
          currencies: currencies,
          valueSymbol: _currencyGlyph(target),
          value: '5078.34',
          label: 'to: ${target.valueName}',
          isActive: false,
          onSelected: onTargetSelected,
        ),
        SizedBox(height: calcTheme.itemSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            '5078.34+1205.67+123.54',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: calcTheme.displayMidTextStyle,
          ),
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
                  _currencyGlyph(target),
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
                      '6407.55',
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
          base: base,
          target: target,
          isExpanded: isExpanded,
          onToggleCalculatorWidth: onToggleCalculatorWidth,
        ),
      ],
    );
  }
}

class _CurrencyInfoDisplay extends StatelessWidget {
  const _CurrencyInfoDisplay({
    Key? key,
    required this.base,
    required this.target,
    required this.isExpanded,
    required this.onToggleCalculatorWidth,
  }) : super(key: key);

  final Currency base;
  final Currency target;
  final bool isExpanded;
  final VoidCallback onToggleCalculatorWidth;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final itemSpacing = AppDimens.currentItemSpacing();

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: calcTheme.accent,
                size: 14,
              ),
              SizedBox(width: itemSpacing),
              Expanded(
                child: Text(
                  '1 ${base.symbol} = 3.6257 ${target.symbol}',
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
          children: [
            OptionIconButton(
              icon: Icons.autorenew,
              tooltip: 'Zamien waluty',
              isActive: false,
              usePressedAccent: true,
              onPressed: () {},
            ),
            SizedBox(width: itemSpacing),
            OptionIconButton(
              icon: isExpanded ? Icons.calculate_outlined : Icons.list,
              tooltip: isExpanded ? 'Zwin liste walut' : 'Pokaz liste walut',
              isActive: false,
              usePressedAccent: true,
              onPressed: onToggleCalculatorWidth,
            ),
            SizedBox(width: itemSpacing),
            OptionIconButton(
              icon: Icons.arrow_upward,
              tooltip: 'Poprzednia wartosc',
              isActive: false,
              usePressedAccent: true,
              onPressed: () {},
            ),
            SizedBox(width: itemSpacing),
            OptionIconButton(
              icon: Icons.arrow_downward,
              tooltip: 'Nastepna wartosc',
              isActive: false,
              usePressedAccent: true,
              onPressed: () {},
            ),
            SizedBox(width: itemSpacing),
            OptionIconButton(
              icon: Icons.backspace_outlined,
              tooltip: 'Usun',
              isActive: false,
              usePressedAccent: true,
              onPressed: () {},
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
  switch (currency.symbol) {
    case 'PLN':
      return 'zł';
    case 'EUR':
      return '€';
    case 'GBP':
      return 'L';
    case 'JPY':
      return '¥';
    default:
      return '\$';
  }
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
