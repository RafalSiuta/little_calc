import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({Key? key, this.date}) : super(key: key);

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final value = date ?? DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppDimens.smallItemSpacing,
      children: [
        Text(
          DateFormat.yMMMd(locale).format(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: calcTheme.displayMidTextStyle.copyWith(
            color: calcTheme.text,
            fontWeight: FontWeight.w200,
          ),
        ),
        Text(
          DateFormat.EEEE(locale).format(value),
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
