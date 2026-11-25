import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../models/currency_model/currency.dart';
import '../../providers/currencies_provider.dart';
import '../../utils/currency_logic/currency_logic.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../utils/system/system_helper.dart';
import '../../widgets/animations/calculation_completion.dart';
import '../../widgets/animations/display_motion.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/buttons/option_icon_button.dart';
import '../../widgets/cards/currency_card.dart';
import '../../widgets/displays/currency_choice_display.dart';
import '../../widgets/displays/currency_equation_display.dart';
import '../../widgets/displays/date_header.dart';
import '../../widgets/nav/calc_tab_bar/calc_tab_bar.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({
    super.key,
    required this.isExpanded,
    required this.keyboardHeight,
    required this.onToggleLayout,
    required this.initialTab,
    required this.onTabChanged,
  });

  final bool isExpanded;
  final double keyboardHeight;
  final VoidCallback onToggleLayout;
  final int initialTab;
  final ValueChanged<int?> onTabChanged;

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int? _reportedTab;

  @override
  void initState() {
    super.initState();
    _reportedTab = widget.initialTab;
    _tabController = TabController(
      length: 3,
      initialIndex: widget.initialTab,
      vsync: this,
    );
    _tabController.addListener(_reportTab);
    _tabController.animation!.addListener(_reportTab);
  }

  @override
  void dispose() {
    _tabController.removeListener(_reportTab);
    _tabController.animation!.removeListener(_reportTab);
    _tabController.dispose();
    super.dispose();
  }

  void _reportTab() {
    final tab =
        _tabController.indexIsChanging || _tabController.offset.abs() > 0.001
        ? null
        : _tabController.index;
    if (tab == _reportedTab) return;

    _reportedTab = tab;
    widget.onTabChanged(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayMotion(
          startScale: 1,
          child: CalcTabBar(
            controller: _tabController,
            tabs: [
              context.tr('pages.currencies'),
              context.tr('pages.commodities'),
              context.tr('pages.crypto'),
            ],
            trailing: OptionIconButton(
              icon: SystemHelper.isMobileSystem && widget.isExpanded
                  ? Icons.calculate_outlined
                  : Icons.show_chart,
              tooltip: widget.isExpanded
                  ? context.tr('actions.hide_currencies')
                  : context.tr('actions.show_currencies'),
              isActive: SystemHelper.isDesktopSystem && widget.isExpanded,
              usePressedAccent: true,
              onPressed: widget.onToggleLayout,
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _CurrenciesTab(
                isExpanded: widget.isExpanded,
                keyboardHeight: widget.keyboardHeight,
              ),
              _PlaceholderPage(title: context.tr('pages.commodities')),
              _PlaceholderPage(title: context.tr('pages.crypto')),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrenciesTab extends StatelessWidget {
  const _CurrenciesTab({
    required this.isExpanded,
    required this.keyboardHeight,
  });

  final bool isExpanded;
  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    final (isLoading, hasCurrencies) = context
        .select<CurrenciesProvider, (bool, bool)>(
          (provider) => (provider.isLoading, provider.currencies.isNotEmpty),
        );

    if (isLoading && !hasCurrencies) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasCurrencies) {
      return _PlaceholderPage(title: context.tr('pages.currencies'));
    }

    final converter = _CurrencyConverter(keyboardHeight: keyboardHeight);
    if (SystemHelper.isMobileSystem) {
      return isExpanded ? const _MobileCurrenciesOverview() : converter;
    }

    if (isExpanded) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: DisplayMotion(startScale: 1, child: _CurrenciesList()),
          ),
          Expanded(child: converter),
        ],
      );
    }

    return converter;
  }
}

class _MobileCurrenciesOverview extends StatelessWidget {
  const _MobileCurrenciesOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final provider = context.watch<CurrenciesProvider>();
    final base = provider.selectedCurrency ?? provider.currencies.first;
    final currencies = [
      base,
      ...provider.currencies.where(
        (currency) => currency.codeIso != base.codeIso,
      ),
    ];

    return AnimationLimiter(
      child: ListView.separated(
        padding: EdgeInsets.all(calcTheme.basePadding),
        itemCount: currencies.length + 1,
        separatorBuilder: (_, _) => SizedBox(height: calcTheme.itemSpacing),
        itemBuilder: (context, index) {
          if (index == 0) {
            return StaggeredEntrance(
              position: 0,
              child: _CurrencyListHeader(onAddPressed: () {}),
            );
          }
          final currency = currencies[index - 1];
          return StaggeredEntrance(
            position: index,
            child: CurrencyCard(
              currency: currency,
              value: provider.valueForCurrency(currency),
              isActive: currency.codeIso == base.codeIso,
              onTap: () => provider.selectCurrency(currency),
            ),
          );
        },
      ),
    );
  }
}

class _CurrenciesList extends StatelessWidget {
  const _CurrenciesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final provider = context.watch<CurrenciesProvider>();
    final base = provider.selectedCurrency ?? provider.currencies.first;
    final currencies = [
      base,
      ...provider.currencies.where(
        (currency) => currency.codeIso != base.codeIso,
      ),
    ];

    return Column(
      children: [
        _CurrencyListHeader(onAddPressed: () {}),
        SizedBox(height: calcTheme.itemSpacing),
        Expanded(
          child: AnimationLimiter(
            child: ListView.separated(
              itemCount: currencies.length,
              padding: EdgeInsets.all(calcTheme.basePadding),
              separatorBuilder: (context, index) =>
                  SizedBox(height: calcTheme.itemSpacing),
              itemBuilder: (context, index) {
                final currency = currencies[index];

                return StaggeredEntrance(
                  position: index,
                  child: CurrencyCard(
                    currency: currency,
                    value: provider.valueForCurrency(currency),
                    isActive: currency.codeIso == base.codeIso,
                    onTap: () => provider.selectCurrency(currency),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyListHeader extends StatelessWidget {
  const _CurrencyListHeader({Key? key, required this.onAddPressed})
    : super(key: key);

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    return Padding(
      padding: SystemHelper.isMobileSystem
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: calcTheme.basePadding),
      child: Row(
        children: [
          const Expanded(child: DateHeader()),
          OptionIconButton(
            icon: Icons.add,
            tooltip: context.tr('actions.add_currency'),
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
  const _CurrencyConverter({required this.keyboardHeight});

  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final provider = context.watch<CurrenciesProvider>();
    final base = provider.baseCurrency ?? provider.currencies.first;
    final target =
        provider.targetCurrency ??
        (provider.currencies.length > 1 ? provider.currencies[1] : base);
    final logic = provider.currencyLogic;
    final resultCurrency = logic.resultCurrency ?? target;
    final resultDisplay = logic.resultDisplay;

    String currencyLabel(Currency currency, bool isSource) {
      final name = context.tr(
        'currency.names.${currency.codeIso}',
        fallback: currency.valueName,
      );
      return context.tr(
        isSource ? 'currency.from' : 'currency.to',
        args: {'currency': name},
      );
    }

    return Padding(
      padding: EdgeInsets.all(
        calcTheme.basePadding,
      ).add(EdgeInsets.only(bottom: keyboardHeight)),
      child: _CurrencyDisplay(
        base: base,
        target: target,
        currencies: provider.currencies,
        baseValue: provider.formatCurrencyValue(logic.baseValueDisplay),
        targetValue: provider.formatCurrencyValue(logic.targetValueDisplay),
        baseLabel: logic.baseLabel(base, target, builder: currencyLabel),
        targetLabel: logic.targetLabel(base, target, builder: currencyLabel),
        equationDisplay: logic.equationDisplay,
        completedCalculations: logic.completedCalculations,
        resultDisplay: resultDisplay == 'Error'
            ? context.tr('errors.generic')
            : provider.formatCurrencyValue(resultDisplay),
        resultCurrency: resultCurrency,
        rateDisplay: logic.rateDisplay(
          base,
          target,
          decimalPlaces: provider.currencyDecimalPlaces(),
        ),
        onBaseSelected: provider.setBaseCurrency,
        onTargetSelected: provider.setTargetCurrency,
        onSwapCurrencies: provider.swapCurrencies,
        onBackspace: logic.delete,
      ),
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
    required this.completedCalculations,
    required this.resultDisplay,
    required this.resultCurrency,
    required this.rateDisplay,
    required this.onBaseSelected,
    required this.onTargetSelected,
    required this.onSwapCurrencies,
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
  final int completedCalculations;
  final String resultDisplay;
  final Currency resultCurrency;
  final String rateDisplay;
  final ValueChanged<Currency> onBaseSelected;
  final ValueChanged<Currency> onTargetSelected;
  final VoidCallback onSwapCurrencies;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final activeDisplay = context.watch<CurrenciesProvider>().isActiveDisplay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DisplayMotion(
          child: CurrencyChoiceDisplay(
            currency: base,
            currencies: currencies,
            valueSymbol: _currencyGlyph(base),
            value: baseValue,
            label: baseLabel,
            isActive: activeDisplay == CurrencyActiveDisplay.base,
            onSelected: onBaseSelected,
            onActivated: () => context
                .read<CurrenciesProvider>()
                .currencyLogic
                .setActiveDisplay(CurrencyActiveDisplay.base),
          ),
        ),
        SizedBox(height: calcTheme.itemSpacing),
        DisplayMotion(
          position: 1,
          child: CurrencyChoiceDisplay(
            currency: target,
            currencies: currencies,
            valueSymbol: _currencyGlyph(target),
            value: targetValue,
            label: targetLabel,
            isActive: activeDisplay == CurrencyActiveDisplay.target,
            onSelected: onTargetSelected,
            onActivated: () => context
                .read<CurrenciesProvider>()
                .currencyLogic
                .setActiveDisplay(CurrencyActiveDisplay.target),
          ),
        ),
        SizedBox(height: calcTheme.itemSpacing),
        DisplayMotion(
          position: 2,
          child: EquationAfterEquals(
            equation: equationDisplay,
            completedCalculations: completedCalculations,
            builder: (visibleEquation) => EquationAppearance(
              hasEquation: visibleEquation.isNotEmpty,
              child: CurrencyEquationDisplay(
                equationDisplay: visibleEquation,
                isActive: activeDisplay == CurrencyActiveDisplay.equation,
              ),
            ),
          ),
        ),
        Expanded(
          child: DisplayMotion(
            position: 3,
            child: ResultAfterEquals(
              completedCalculations: completedCalculations,
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [calcTheme.accent, calcTheme.accent2],
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
                          colors: [calcTheme.accent, calcTheme.accent2],
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
          ),
        ),
        DisplayMotion(
          position: 3,
          startScale: 1,
          child: _CurrencyInfoDisplay(
            rateDisplay: rateDisplay,
            onSwapCurrencies: onSwapCurrencies,
            onBackspace: onBackspace,
          ),
        ),
      ],
    );
  }
}

class _CurrencyInfoDisplay extends StatelessWidget {
  const _CurrencyInfoDisplay({
    Key? key,
    required this.rateDisplay,
    required this.onSwapCurrencies,
    required this.onBackspace,
    this.showActions = true,
  }) : super(key: key);

  final String rateDisplay;
  final VoidCallback onSwapCurrencies;
  final VoidCallback onBackspace;
  final bool showActions;

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
              Icon(Icons.info_outline, color: calcTheme.accent, size: 14),
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
        if (showActions)
          Row(
            spacing: itemSpacing,
            children: [
              OptionIconButton(
                icon: Icons.autorenew,
                tooltip: context.tr('actions.swap_currencies'),
                isActive: false,
                usePressedAccent: true,
                onPressed: onSwapCurrencies,
              ),
              Consumer<CurrenciesProvider>(
                builder: (context, provider, child) {
                  return OptionIconButton(
                    icon: Icons.arrow_upward,
                    tooltip: context.tr('actions.previous_value'),
                    isActive: false,
                    usePressedAccent: true,
                    onPressed: () => provider.toggleActiveDisplay(next: false),
                  );
                },
              ),
              Consumer<CurrenciesProvider>(
                builder: (context, provider, child) {
                  return OptionIconButton(
                    icon: Icons.arrow_downward,
                    tooltip: context.tr('actions.next_value'),
                    isActive: false,
                    usePressedAccent: true,
                    onPressed: () => provider.toggleActiveDisplay(next: true),
                  );
                },
              ),
              OptionIconButton(
                icon: Icons.backspace_outlined,
                tooltip: context.tr('actions.delete'),
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
      child: Text(title, style: context.calcTheme.placeholderTextStyle),
    );
  }
}

String _currencyGlyph(Currency currency) {
  return currency.symbol;
}
