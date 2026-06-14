import '../../system/system_helper.dart';

class AppDimens {
  static const double borderThickness = 0.3;
  static const double basePadding = 16;
  static const double paddingSmall = 8;
  static const double smallItemSpacing = 5;
  static const double itemSpacing = 16;
  static const double mobileItemSpacing = 8;
  static const double keyHeight = 54;
  static const double mobileKeyHeight = 319 / 6;
  static const double mobileExpandedKeyHeight = 466 / 12;
  static const double optionsBarHeight = 78;
  static const double mobileOptionsBarHeight = 56;
  static const double buttonPaddingHorizontal = 16;
  static const double buttonPaddingVertical = 16;
  static const double mobileExpandedButtonPaddingVertical = 8;
  static const double cornerMedium = 12;

  static double buttonHorizontalPadding() {
    if (SystemHelper.isMobileSystem) {
      return buttonPaddingHorizontal;
    }

    return buttonPaddingHorizontal;
  }

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

  static double calculatorOptionsBarHeight() {
    if (SystemHelper.isMobileSystem) {
      return mobileOptionsBarHeight;
    }

    return optionsBarHeight;
  }

  static double currentItemSpacing() {
    if (SystemHelper.isMobileSystem) {
      return mobileItemSpacing;
    }

    return itemSpacing;
  }
}
