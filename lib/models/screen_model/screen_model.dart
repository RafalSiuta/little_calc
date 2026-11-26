import '../../utils/custom_icons/bixcalc_icons.dart';
import '../nav_model/nav_model.dart';

enum ScreenModel {
  calculator(
    NavModel(
      title: 'navigation.calculator',
      icon: BixCalcIcons.calculator_simple,
    ),
  ),
  units(NavModel(title: 'navigation.units', icon: BixCalcIcons.ruler_triangle)),
  // currencies(NavModel(title: 'waluty', icon: BixCalcIcons.sack_dollar)),
  // history(NavModel(title: 'historia', icon: BixCalcIcons.history)),
  settings(NavModel(title: 'navigation.settings', icon: BixCalcIcons.settings));

  const ScreenModel(this.nav);

  final NavModel nav;
}
