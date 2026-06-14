import 'package:flutter/material.dart';

import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({
    Key? key,
    this.date,
  }) : super(key: key);

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final value = date ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppDimens.smallItemSpacing,
      children: [
        Text(
          '${value.day} ${_monthName(value.month)} ${value.year}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: calcTheme.displayMidTextStyle.copyWith(
            color: calcTheme.text,
            fontWeight: FontWeight.w200,
          ),
        ),
        Text(
          _weekdayName(value.weekday),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: calcTheme.displaySmallTextStyle.copyWith(
            color: calcTheme.text,
          ),
        ),
      ],
    );
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
