import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/currency_model/currency.dart';
import '../../providers/currencies_provider.dart';
import '../../utils/styles/theme.dart';
import '../displays/currency_choice_display.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    Key? key,
    required this.currency,
    this.onTap,
  }) : super(key: key);

  final Currency currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final decimalPlaces = context.select<CurrenciesProvider, int>(
      (provider) => provider.currencyDecimalPlaces(),
    );
    final values = currency.currencyValues;
    final latestValue = values.isNotEmpty
        ? values.last.numericValue.toStringAsFixed(decimalPlaces)
        : '-';
    final isRising = values.length < 2 ||
        values.last.numericValue >= values[values.length - 2].numericValue;
    final accentColor = isRising ? calcTheme.accent : calcTheme.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 82,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 406),
          padding: EdgeInsets.symmetric(vertical: calcTheme.basePadding),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: calcTheme.borderDark,
                width: calcTheme.borderThickness*2,
                // strokeAlign: BorderSide.strokeAlignOutside
              ),
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: calcTheme.backgroundShadow,
            //     offset: const Offset(0.5, 0.5),
            //     blurRadius: 0.5,
            //     spreadRadius: 0.5,
            //   ),
            // ],
          ),
          child: Row(
            children: [
              _CurrencyCardLabel(currency: currency),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: calcTheme.basePadding,
                  ),
                  child: SizedBox(
                    height: 33,
                    child: _CurrencyChart(
                      values: values,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currency.symbol,
                    style: calcTheme.numButtonNumberTextStyle.copyWith(
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    latestValue,
                    style: calcTheme.numButtonNumberTextStyle.copyWith(
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    isRising ? Icons.arrow_upward : Icons.arrow_downward,
                    color: accentColor,
                    size: 24,
                  ),
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
  const _CurrencyCardLabel({
    Key? key,
    required this.currency,
  }) : super(key: key);

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          spacing: 5,
          children: [
            CurrencyFlag(currency: currency),
            Text(
              currency.codeIso,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: calcTheme.numButtonNumberTextStyle.copyWith(
                color: calcTheme.text,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: calcTheme.text,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          currency.valueName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: calcTheme.numButtonNumberTextStyle.copyWith(
            color: calcTheme.text,
            fontSize: 10.32,
          ),
        ),
      ],
    );
  }
}

class _CurrencyChart extends StatelessWidget {
  const _CurrencyChart({
    Key? key,
    required this.values,
    required this.color,
  }) : super(key: key);

  final List<CurrencyValue> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final chartValues =
        values.length > 5 ? values.sublist(values.length - 5) : values;
    final spots = <FlSpot>[
      for (var i = 0; i < chartValues.length; i++)
        FlSpot(i.toDouble(), chartValues[i].numericValue),
    ];

    if (spots.length < 2) {
      return const SizedBox.shrink();
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 1,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
