import '../../system/system_helper.dart';

class AppDimens {
  static const double borderThickness = 0.3;
  static const double basePadding = 16;
  static const double paddingSmall = 8;
  static const double smallItemSpacing = 5;
  static const double itemSpacing = 16;
  static const double mobileItemSpacing = 10;
  static const double keyHeight = 54;
  static const double mobileKeyHeight = 319 / 6;
  static const double mobileExpandedKeyHeight = 466 / 12;
  static const double buttonPaddingHorizontal = 16;
  static const double buttonPaddingVertical = 16;
  static const double mobileExpandedButtonPaddingVertical = 8;
  static const double windowBorderRadius = 16;
  static const double menuIndicatorHeight = 2;
  static const double thumbSize = 16;
  static const double thumbTrackHeight = 12;
  static const double sliderTrackHeight = 2;
  static const double cardBorderRadius = 10;
  static const double baseIconSize = 24;
  static const double mobileBaseIconSize = 20;
  static const double midIconSize = 16;
  static const double smallIconSize = 12;
  static const double expandCalculatorIconWidth = 32;
  static const double displayInfoSpacing = 10;
  static const double windowTitleBarVerticalPadding = 10;

  static double get currentBaseIconSize =>
      SystemHelper.isMobileSystem ? mobileBaseIconSize : baseIconSize;

  static double buttonVerticalPadding({bool isExpanded = false}) {
    if (SystemHelper.isMobileSystem && isExpanded) {
      return mobileExpandedButtonPaddingVertical;
    }

    return buttonPaddingVertical;
  }

  static double calculatorKeyHeight({bool isExpanded = false}) {
    if (SystemHelper.isMobileSystem && isExpanded) {
      return mobileExpandedKeyHeight;
    }
    if (SystemHelper.isMobileSystem) {
      return mobileKeyHeight;
    }

    return keyHeight;
  }

  static double calculatorKeyboardHeight({bool isExpanded = false}) {
    final rowsCount = isExpanded && SystemHelper.isMobileSystem ? 12 : 6;
    return calculatorKeyHeight(isExpanded: isExpanded) * rowsCount;
  }

  static double currentItemSpacing() {
    if (SystemHelper.isMobileSystem) {
      return mobileItemSpacing;
    }

    return itemSpacing;
  }
}
