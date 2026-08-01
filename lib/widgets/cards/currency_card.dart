import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/currency_model/currency.dart';
import '../../utils/styles/theme.dart';
import '../displays/currency_choice_display.dart';

class CurrencyCard extends StatefulWidget {
  const CurrencyCard({
    Key? key,
    required this.currency,
    required this.value,
    required this.isActive,
    this.onTap,
  }) : super(key: key);

  final Currency currency;
  final String value;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    final values = widget.currency.currencyValues;
    final isRising = values.length < 2 ||
        values.last.numericValue >= values[values.length - 2].numericValue;
    final valueColor = isRising ? theme.accent : theme.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          height: 82,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 406),
          padding: EdgeInsets.symmetric(
            horizontal: theme.paddingSmall,
            vertical: theme.basePadding,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? theme.accentFill : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: widget.isActive
                    ? theme.accent
                    : _isHovered
                        ? Colors.transparent
                        : theme.borderDark,
                width: theme.borderThickness,
              ),
            ),
            borderRadius: widget.isActive
                    ? null
                    : BorderRadius.circular(theme.itemSpacing),
          ),
          child: Row(
            children: [
              _CurrencyCardLabel(
                currency: widget.currency,
                isActive: widget.isActive,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.basePadding),
                  child: SizedBox(
                    height: 33,
                    child: _CurrencyChart(values: values, color: valueColor),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(widget.currency.symbol,
                      style: theme.numButtonNumberTextStyle.copyWith(color: valueColor)),
                  const SizedBox(width: 5),
                  Text(widget.value,
                      style: theme.numButtonNumberTextStyle.copyWith(color: valueColor)),
                  const SizedBox(width: 5),
                  Icon(isRising ? Icons.arrow_upward : Icons.arrow_downward,
                      color: valueColor, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyCardLabel extends StatelessWidget {
  const _CurrencyCardLabel({required this.currency, required this.isActive});
  final Currency currency;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          CurrencyFlag(currency: currency),
          Text(currency.codeIso,
              style: theme.numButtonNumberTextStyle.copyWith(color: theme.text)),
          if (isActive) Icon(Icons.arrow_drop_down, color: theme.text, size: 24),
        ]),
        const SizedBox(height: 5),
        Text(currency.valueName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.numButtonNumberTextStyle.copyWith(color: theme.text, fontSize: 10.32)),
      ],
    );
  }
}

class _CurrencyChart extends StatelessWidget {
  const _CurrencyChart({required this.values, required this.color});
  final List<CurrencyValue> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final chartValues = values.length > 5 ? values.sublist(values.length - 5) : values;
    final spots = <FlSpot>[
      for (var i = 0; i < chartValues.length; i++)
        FlSpot(i.toDouble(), chartValues[i].numericValue),
    ];
    if (spots.length < 2) return const SizedBox.shrink();
    return LineChart(LineChartData(
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [LineChartBarData(
        spots: spots,
        isCurved: true,
        barWidth: 1,
        color: color,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      )],
    ));
  }
}
