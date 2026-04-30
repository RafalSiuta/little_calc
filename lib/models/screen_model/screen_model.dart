import 'package:flutter/widgets.dart';

import '../nav_model/nav_model.dart';

class ScreenModel {
  const ScreenModel({
    required this.page,
    required this.nav,
  });

  final Widget page;
  final NavModel nav;
}
