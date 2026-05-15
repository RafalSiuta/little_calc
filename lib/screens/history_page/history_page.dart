import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: 'Historia kalkulacji');
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
