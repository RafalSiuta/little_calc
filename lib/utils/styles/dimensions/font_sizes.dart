import '../../system/system_helper.dart';

class AppFontSizes {
  static const double displayLargeFontSize = 48;
  static const double displayMidFontSize = 24;
  static const double displaySmallFontSize = 14;
  static const double buttonFontSize = 16;
  static const double windowTitleFontSize = 10;

  static double displayLarge() {
    if (SystemHelper.isMobileSystem) {
      return displayLargeFontSize;
    }

    return displayLargeFontSize;
  }

  static double displayMid() {
    if (SystemHelper.isMobileSystem) {
      return displayMidFontSize;
    }

    return displayMidFontSize;
  }

  static double displaySmall() {
    if (SystemHelper.isMobileSystem) {
      return displaySmallFontSize;
    }

    return displaySmallFontSize;
  }

  static double button() {
    if (SystemHelper.isMobileSystem) {
      return buttonFontSize;
    }

    return buttonFontSize;
  }

  static double windowTitle() {
    if (SystemHelper.isMobileSystem) {
      return windowTitleFontSize;
    }

    return windowTitleFontSize;
  }
}
