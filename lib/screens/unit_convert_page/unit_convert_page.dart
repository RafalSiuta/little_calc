import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/custom_icons/bixcalc_icons.dart';
import '../../utils/extensions/number_formatter.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../utils/system/system_helper.dart';
import '../../utils/unit_converter_logic/unit_converter_logic.dart';
import '../../utils/unit_converter_logic/unit_definitions.dart';
import '../../widgets/animations/calculation_completion.dart';
import '../../widgets/animations/display_motion.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/buttons/option_icon_button.dart';
import '../../widgets/cards/unit_card.dart';
import '../../widgets/displays/unit_converter_display.dart';
import '../../widgets/displays/unit_equation_display.dart';
import '../../widgets/nav/calc_tab_bar/calc_tab_bar.dart';

class UnitConvertPage extends StatefulWidget {
  const UnitConvertPage({
    super.key,
    required this.isExpanded,
    required this.keyboardHeight,
    required this.onToggleLayout,
  });

  final bool isExpanded;
  final double keyboardHeight;
  final VoidCallback onToggleLayout;

  @override
  State<UnitConvertPage> createState() => _UnitConvertPageState();
}

class _UnitConvertPageState extends State<UnitConvertPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: UnitCategory.values.length,
      initialIndex: context.read<UnitConverterLogic>().category.index,
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
    return Column(
      children: [
        DisplayMotion(
          startScale: 1,
          child: CalcTabBar(
            controller: _tabController,
            tabs: [
              for (final category in UnitCategory.values)
                context.tr('units.categories.${category.name}'),
            ],
            trailing: OptionIconButton(
              icon: SystemHelper.isMobileSystem && widget.isExpanded
                  ? BixCalcIcons.calculator_simple
                  : BixCalcIcons.rectangle_list,
              tooltip: widget.isExpanded
                  ? context.tr('actions.hide_units')
                  : context.tr('actions.show_units'),
              isActive: SystemHelper.isDesktopSystem && widget.isExpanded,
              usePressedAccent: true,
              onPressed: widget.onToggleLayout,
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.filled(
              UnitCategory.values.length,
              _UnitCategoryView(
                isExpanded: widget.isExpanded,
                keyboardHeight: widget.keyboardHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitCategoryView extends StatelessWidget {
  const _UnitCategoryView({
    required this.isExpanded,
    required this.keyboardHeight,
  });

  final bool isExpanded;
  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    final converter = _UnitConverter(keyboardHeight: keyboardHeight);
    if (SystemHelper.isMobileSystem) {
      return isExpanded ? const _UnitList() : converter;
    }

    return isExpanded
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: DisplayMotion(startScale: 1, child: _UnitList()),
              ),
              Expanded(child: converter),
            ],
          )
        : converter;
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

    return AnimationLimiter(
      child: ListView.separated(
        padding: EdgeInsets.all(theme.basePadding),
        itemCount: units.length,
        separatorBuilder: (_, __) => SizedBox(height: theme.itemSpacing),
        itemBuilder: (_, index) {
          final unit = units[index];
          return StaggeredEntrance(
            position: index,
            child: UnitCard(
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
            ),
          );
        },
      ),
    );
  }
}

class _UnitConverter extends StatelessWidget {
  const _UnitConverter({required this.keyboardHeight});

  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    final logic = context.watch<UnitConverterLogic>();

    final equation = logic.equationDisplay;

    return Padding(
      padding: EdgeInsets.all(
        theme.basePadding,
      ).add(EdgeInsets.only(bottom: keyboardHeight)),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          primary: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DisplayMotion(
                    child: UnitConverterDisplay(
                      unit: logic.sourceUnit,
                      units: logic.availableUnits,
                      value: logic.sourceValue,
                      isActive: logic.activeDisplay == UnitActiveDisplay.source,
                      onSelected: () =>
                          logic.setActiveDisplay(UnitActiveDisplay.source),
                      onUnitSelected: logic.setSourceUnit,
                    ),
                  ),
                  SizedBox(height: theme.itemSpacing),
                  DisplayMotion(
                    position: 1,
                    child: UnitConverterDisplay(
                      unit: logic.targetUnit,
                      units: logic.availableUnits,
                      value: logic.targetValue,
                      isActive: logic.activeDisplay == UnitActiveDisplay.target,
                      onSelected: () =>
                          logic.setActiveDisplay(UnitActiveDisplay.target),
                      onUnitSelected: logic.setTargetUnit,
                    ),
                  ),
                  SizedBox(height: theme.itemSpacing),
                  DisplayMotion(
                    position: 2,
                    child: EquationAfterEquals(
                      equation: equation,
                      completedCalculations: logic.completedCalculations,
                      builder: (visibleEquation) => EquationAppearance(
                        hasEquation: visibleEquation.isNotEmpty,
                        child: UnitEquationDisplay(
                          equationDisplay: visibleEquation,
                          isActive:
                              logic.activeDisplay == UnitActiveDisplay.equation,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: DisplayMotion(
                      position: 3,
                      child: ResultAfterEquals(
                        completedCalculations: logic.completedCalculations,
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
                    ),
                  ),
                  DisplayMotion(
                    position: 3,
                    startScale: 1,
                    child: Row(
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
                            // OptionIconButton(
                            //   icon: Icons.autorenew,
                            //   tooltip: 'Zamień jednostki',
                            //   isActive: false,
                            //   usePressedAccent: true,
                            //   onPressed: logic.swapUnits,
                            // ),
                            OptionIconButton(
                              icon: BixCalcIcons.arrow_up,
                              tooltip: context.tr('actions.previous_value'),
                              isActive: false,
                              usePressedAccent: true,
                              onPressed: () =>
                                  logic.toggleActiveDisplay(next: false),
                            ),
                            OptionIconButton(
                              icon: BixCalcIcons.arrow_down,
                              tooltip: context.tr('actions.next_value'),
                              isActive: false,
                              usePressedAccent: true,
                              onPressed: () =>
                                  logic.toggleActiveDisplay(next: true),
                            ),
                            // OptionIconButton(
                            //   icon: Icons.backspace_outlined,
                            //   tooltip: 'Usuń',
                            //   isActive: false,
                            //   usePressedAccent: true,
                            //   onPressed: logic.delete,
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
