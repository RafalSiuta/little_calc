import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/window_layout_provider.dart';
import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/extensions/number_formatter.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../utils/system/system_helper.dart';
import '../../utils/unit_converter_logic/unit_converter_logic.dart';
import '../../utils/unit_converter_logic/unit_definitions.dart';
import '../../widgets/buttons/option_icon_button.dart';
import '../../widgets/cards/unit_card.dart';
import '../../widgets/displays/unit_converter_display.dart';
import '../../widgets/displays/unit_equation_display.dart';
import '../../widgets/displays/unit_header.dart';
import '../../widgets/keyboards/calculator_keyboard.dart';
import '../../widgets/nav/calc_tab_bar/calc_tab_bar.dart';

class UnitConvertPage extends StatefulWidget {
  const UnitConvertPage({Key? key}) : super(key: key);

  @override
  State<UnitConvertPage> createState() => _UnitConvertPageState();
}

class _UnitConvertPageState extends State<UnitConvertPage> {
  late final UnitConverterLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = UnitConverterLogic();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _logic,
      child: const _UnitConvertContent(),
    );
  }
}

class _UnitConvertContent extends StatefulWidget {
  const _UnitConvertContent();

  @override
  State<_UnitConvertContent> createState() => _UnitConvertContentState();
}

class _UnitConvertContentState extends State<_UnitConvertContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: UnitCategory.values.length,
      vsync: this,
    )..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<UnitConverterLogic>().setCategory(
            UnitCategory.values[_tabController.index],
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<WindowLayoutProvider>();

    return Column(
      children: [
        CalcTabBar(
          controller: _tabController,
          tabs: [
            for (final category in UnitCategory.values)
              UnitDefinitions.categoryNames[category]!,
          ],
          trailing: OptionIconButton(
            icon: SystemHelper.isMobileSystem && layout.isExpanded
                ? Icons.calculate_outlined
                : Icons.list_alt_outlined,
            tooltip: layout.isExpanded
                ? 'Zwiń listę jednostek'
                : 'Pokaż listę jednostek',
            isActive: SystemHelper.isDesktopSystem && layout.isExpanded,
            usePressedAccent: true,
            onPressed: layout.toggleCalculatorWidth,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:  [
              for (final category in UnitCategory.values) _UnitCategoryView(),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnitCategoryView extends StatelessWidget {
  const _UnitCategoryView();

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<WindowLayoutProvider>();

    if (SystemHelper.isMobileSystem) {
      return layout.isExpanded ? const _UnitList() : const _UnitConverter();
    }

    return layout.isExpanded
        ? const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _UnitList()),
              Expanded(child: _UnitConverter()),
            ],
          )
        : const _UnitConverter();
  }
}

class _UnitList extends StatelessWidget {
  const _UnitList();

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    final logic = context.watch<UnitConverterLogic>();
    final units = [
      logic.selectedUnit,
      ...logic.availableUnits.where((unit) => unit != logic.selectedUnit),
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.basePadding),
          child: Align(
            alignment: Alignment.centerLeft,
            child: UnitHeader(
              title: UnitDefinitions.listHeaderNames[logic.category]!,
            ),
          ),
        ),
        SizedBox(height: theme.itemSpacing),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(theme.basePadding),
            itemCount: units.length,
            separatorBuilder: (_, __) => SizedBox(height: theme.itemSpacing),
            itemBuilder: (_, index) {
              final unit = units[index];
              return UnitCard(
                unit: unit,
                value: unit == logic.selectedUnit
                    ? (logic.activeDisplay == UnitActiveDisplay.target
                        ? logic.targetValue
                        : logic.sourceValue)
                    : numberFormatter(
                        logic.convertedValueFor(unit),
                        decimalPlaces: 10,
                      ),
                isActive: unit == logic.selectedUnit,
                onTap: () => logic.selectUnit(unit),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UnitConverter extends StatelessWidget {
  const _UnitConverter();

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    final logic = context.watch<UnitConverterLogic>();

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(theme.basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                UnitConverterDisplay(
                  unit: logic.sourceUnit,
                  units: logic.availableUnits,
                  value: logic.sourceValue,
                  isActive: logic.activeDisplay == UnitActiveDisplay.source,
                  onSelected: () =>
                      logic.setActiveDisplay(UnitActiveDisplay.source),
                  onUnitSelected: logic.setSourceUnit,
                ),
                SizedBox(height: theme.itemSpacing),
                UnitConverterDisplay(
                  unit: logic.targetUnit,
                  units: logic.availableUnits,
                  value: logic.targetValue,
                  isActive: logic.activeDisplay == UnitActiveDisplay.target,
                  onSelected: () =>
                      logic.setActiveDisplay(UnitActiveDisplay.target),
                  onUnitSelected: logic.setTargetUnit,
                ),
                SizedBox(height: theme.itemSpacing),
                UnitEquationDisplay(
                  equationDisplay: logic.equationDisplay,
                  isActive: logic.activeDisplay == UnitActiveDisplay.equation,
                ),
                const Spacer(),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${logic.resultValue} ${logic.resultUnit.symbol}',
                        style: theme.displayLargeTextStyle,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        logic.rateDisplay(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.displaySmallTextStyle.copyWith(
                          color: theme.accent,
                        ),
                      ),
                    ),
                    Row(
                      spacing: AppDimens.currentItemSpacing(),
                      children: [
                        OptionIconButton(
                          icon: Icons.autorenew,
                          tooltip: 'Zamień jednostki',
                          isActive: false,
                          usePressedAccent: true,
                          onPressed: logic.swapUnits,
                        ),
                        OptionIconButton(
                          icon: Icons.arrow_upward,
                          tooltip: 'Poprzednia wartość',
                          isActive: false,
                          usePressedAccent: true,
                          onPressed: () =>
                              logic.toggleActiveDisplay(next: false),
                        ),
                        OptionIconButton(
                          icon: Icons.arrow_downward,
                          tooltip: 'Następna wartość',
                          isActive: false,
                          usePressedAccent: true,
                          onPressed: () =>
                              logic.toggleActiveDisplay(next: true),
                        ),
                        OptionIconButton(
                          icon: Icons.backspace_outlined,
                          tooltip: 'Usuń',
                          isActive: false,
                          usePressedAccent: true,
                          onPressed: logic.delete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        CalculatorKeyboard(
          rows: CalcSymbols.compactRows,
          onPressed: (value) {
            final logicValue = CalcSymbols.logicValue(value);
            if (logicValue.isNotEmpty) {
              logic.handleKeyPress(logicValue);
            }
          },
        ),
      ],
    );
  }
}
