import '../../system/system_helper.dart';

enum AppFontSizeMode { standard, mobile, desktop, small }

class AppFontSizes {
  static const double displayLargeFontSize = 48;
  static const double displayMidFontSize = 24;
  static const double displaySmallFontSize = 14;
  static const double buttonFontSize = 16;
  static const double windowTitleFontSize = 10;

  static AppFontSizeMode get platformMode {
    if (SystemHelper.isMobileSystem) return AppFontSizeMode.mobile;
    if (SystemHelper.isDesktopSystem) return AppFontSizeMode.desktop;
    return AppFontSizeMode.standard;
  }

  static double button({AppFontSizeMode mode = AppFontSizeMode.standard}) =>
      mode == AppFontSizeMode.small ? 8 : buttonFontSize;

  static double functionButton(AppFontSizeMode mode) => switch (mode) {
    AppFontSizeMode.standard || AppFontSizeMode.mobile => 12,
    AppFontSizeMode.desktop || AppFontSizeMode.small => button(mode: mode),
  };
}
