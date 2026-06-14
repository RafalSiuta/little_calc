import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'dimensions/dimensions.dart';
import 'dimensions/font_sizes.dart';

class CalcTheme extends ThemeExtension<CalcTheme> {
  const CalcTheme({
    required this.systemWindow,
    required this.background,
    required this.borderDark,
    required this.text,
    required this.numbersText,
    required this.operatorsText,
    required this.functionsText,
    required this.accent,
    required this.accent2,
    required this.unselected,
    required this.unselectedHover,
    required this.error,
    required this.displayLargeTextStyle,
    required this.displayMidTextStyle,
    required this.displaySmallTextStyle,
    required this.numButtonNumberTextStyle,
    required this.numButtonOperatorTextStyle,
    required this.numButtonFunctionTextStyle,
    required this.numButtonPressedTextStyle,
    required this.windowTitleTextStyle,
    required this.placeholderTextStyle,
    required this.optionIconButtonSize,
    required this.optionIconButtonPadding,
    required this.optionIconSize,
    required this.windowActionButtonSize,
    required this.windowActionBorderRadius,
    required this.windowActionHoverColor,
    required this.windowActionSplashColor,
    required this.windowActionHighlightColor,
    required this.basePadding,
    required this.paddingSmall,
    required this.itemSpacing,
    required this.borderThickness,
    required this.cardBorderRadius,
    required this.windowBorderRadius,
    required this.menuIndicatorHeight,
    required this.backgroundShadow,
    required this.settingsTitleTextStyle,
    required this.settingsCardTextStyle,
    required this.settingsCardValueTextStyle,
    required this.settingsCardAccentValueTextStyle,
    required this.tabTextStyle,
    required this.themeCardTextStyle,
    required this.themeCardButtonTextStyle,
    required this.sliderTrackHeight,
    required this.sliderThumbSize,
    required this.switchTrackHeight,
    required this.switchThumbSize,
  });

  final Color systemWindow;
  final Color background;
  final Color borderDark;
  final Color text;
  final Color numbersText;
  final Color operatorsText;
  final Color functionsText;
  final Color accent;
  final Color accent2;
  final Color unselected;
  final Color unselectedHover;
  final Color error;
  final TextStyle displayLargeTextStyle;
  final TextStyle displayMidTextStyle;
  final TextStyle displaySmallTextStyle;
  final TextStyle numButtonNumberTextStyle;
  final TextStyle numButtonOperatorTextStyle;
  final TextStyle numButtonFunctionTextStyle;
  final TextStyle numButtonPressedTextStyle;
  final TextStyle windowTitleTextStyle;
  final TextStyle placeholderTextStyle;
  final Size optionIconButtonSize;
  final EdgeInsetsGeometry optionIconButtonPadding;
  final double optionIconSize;
  final Size windowActionButtonSize;
  final BorderRadius windowActionBorderRadius;
  final Color windowActionHoverColor;
  final Color windowActionSplashColor;
  final Color windowActionHighlightColor;
  final double basePadding;
  final double paddingSmall;
  final double itemSpacing;
  final double borderThickness;
  final double cardBorderRadius;
  final double windowBorderRadius;
  final double menuIndicatorHeight;
  final Color backgroundShadow;
  final TextStyle settingsTitleTextStyle;
  final TextStyle settingsCardTextStyle;
  final TextStyle settingsCardValueTextStyle;
  final TextStyle settingsCardAccentValueTextStyle;
  final TextStyle tabTextStyle;
  final TextStyle themeCardTextStyle;
  final TextStyle themeCardButtonTextStyle;
  final double sliderTrackHeight;
  final double sliderThumbSize;
  final double switchTrackHeight;
  final double switchThumbSize;

  static CalcTheme fromThemeId(int themeId) {
    switch (themeId) {
      case 3:
        return _themeTwo;
      case 2:
        return _themeOne;
      case 1:
      default:
        return _default;
    }
  }

  static ThemeData themeData(int themeId) {
    final calcTheme = CalcTheme.fromThemeId(themeId);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: Colors.transparent,
        primary: calcTheme.accent,
        secondary: calcTheme.accent2,
        error: calcTheme.error,
      ),
      canvasColor: Colors.transparent,
      cardColor: Colors.transparent,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: TextTheme(
        displayLarge: calcTheme.displayLargeTextStyle,
        displayMedium: calcTheme.displayMidTextStyle,
        displaySmall: calcTheme.displaySmallTextStyle,
      ),
      extensions: <ThemeExtension<dynamic>>[
        calcTheme,
      ],
    );
  }

  @override
  CalcTheme copyWith({
    Color? systemWindow,
    Color? background,
    Color? borderDark,
    Color? text,
    Color? numbersText,
    Color? operatorsText,
    Color? functionsText,
    Color? accent,
    Color? accent2,
    Color? unselected,
    Color? unselectedHover,
    Color? error,
    TextStyle? displayLargeTextStyle,
    TextStyle? displayMidTextStyle,
    TextStyle? displaySmallTextStyle,
    TextStyle? numButtonNumberTextStyle,
    TextStyle? numButtonOperatorTextStyle,
    TextStyle? numButtonFunctionTextStyle,
    TextStyle? numButtonPressedTextStyle,
    TextStyle? windowTitleTextStyle,
    TextStyle? placeholderTextStyle,
    Size? optionIconButtonSize,
    EdgeInsetsGeometry? optionIconButtonPadding,
    double? optionIconSize,
    Size? windowActionButtonSize,
    BorderRadius? windowActionBorderRadius,
    Color? windowActionHoverColor,
    Color? windowActionSplashColor,
    Color? windowActionHighlightColor,
    double? basePadding,
    double? paddingSmall,
    double? itemSpacing,
    double? borderThickness,
    double? cardBorderRadius,
    double? windowBorderRadius,
    double? menuIndicatorHeight,
    Color? backgroundShadow,
    TextStyle? settingsTitleTextStyle,
    TextStyle? settingsCardTextStyle,
    TextStyle? settingsCardValueTextStyle,
    TextStyle? settingsCardAccentValueTextStyle,
    TextStyle? tabTextStyle,
    TextStyle? themeCardTextStyle,
    TextStyle? themeCardButtonTextStyle,
    double? sliderTrackHeight,
    double? sliderThumbSize,
    double? switchTrackHeight,
    double? switchThumbSize,
  }) {
    return CalcTheme(
      systemWindow: systemWindow ?? this.systemWindow,
      background: background ?? this.background,
      borderDark: borderDark ?? this.borderDark,
      text: text ?? this.text,
      numbersText: numbersText ?? this.numbersText,
      operatorsText: operatorsText ?? this.operatorsText,
      functionsText: functionsText ?? this.functionsText,
      accent: accent ?? this.accent,
      accent2: accent2 ?? this.accent2,
      unselected: unselected ?? this.unselected,
      unselectedHover: unselectedHover ?? this.unselectedHover,
      error: error ?? this.error,
      displayLargeTextStyle:
          displayLargeTextStyle ?? this.displayLargeTextStyle,
      displayMidTextStyle: displayMidTextStyle ?? this.displayMidTextStyle,
      displaySmallTextStyle:
          displaySmallTextStyle ?? this.displaySmallTextStyle,
      numButtonNumberTextStyle:
          numButtonNumberTextStyle ?? this.numButtonNumberTextStyle,
      numButtonOperatorTextStyle:
          numButtonOperatorTextStyle ?? this.numButtonOperatorTextStyle,
      numButtonFunctionTextStyle:
          numButtonFunctionTextStyle ?? this.numButtonFunctionTextStyle,
      numButtonPressedTextStyle:
          numButtonPressedTextStyle ?? this.numButtonPressedTextStyle,
      windowTitleTextStyle: windowTitleTextStyle ?? this.windowTitleTextStyle,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
      optionIconButtonSize: optionIconButtonSize ?? this.optionIconButtonSize,
      optionIconButtonPadding:
          optionIconButtonPadding ?? this.optionIconButtonPadding,
      optionIconSize: optionIconSize ?? this.optionIconSize,
      windowActionButtonSize:
          windowActionButtonSize ?? this.windowActionButtonSize,
      windowActionBorderRadius:
          windowActionBorderRadius ?? this.windowActionBorderRadius,
      windowActionHoverColor:
          windowActionHoverColor ?? this.windowActionHoverColor,
      windowActionSplashColor:
          windowActionSplashColor ?? this.windowActionSplashColor,
      windowActionHighlightColor:
          windowActionHighlightColor ?? this.windowActionHighlightColor,
      basePadding: basePadding ?? this.basePadding,
      paddingSmall: paddingSmall ?? this.paddingSmall,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      borderThickness: borderThickness ?? this.borderThickness,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      windowBorderRadius: windowBorderRadius ?? this.windowBorderRadius,
      menuIndicatorHeight: menuIndicatorHeight ?? this.menuIndicatorHeight,
      backgroundShadow: backgroundShadow ?? this.backgroundShadow,
      settingsTitleTextStyle:
          settingsTitleTextStyle ?? this.settingsTitleTextStyle,
      settingsCardTextStyle:
          settingsCardTextStyle ?? this.settingsCardTextStyle,
      settingsCardValueTextStyle:
          settingsCardValueTextStyle ?? this.settingsCardValueTextStyle,
      settingsCardAccentValueTextStyle: settingsCardAccentValueTextStyle ??
          this.settingsCardAccentValueTextStyle,
      tabTextStyle: tabTextStyle ?? this.tabTextStyle,
      themeCardTextStyle: themeCardTextStyle ?? this.themeCardTextStyle,
      themeCardButtonTextStyle:
          themeCardButtonTextStyle ?? this.themeCardButtonTextStyle,
      sliderTrackHeight: sliderTrackHeight ?? this.sliderTrackHeight,
      sliderThumbSize: sliderThumbSize ?? this.sliderThumbSize,
      switchTrackHeight: switchTrackHeight ?? this.switchTrackHeight,
      switchThumbSize: switchThumbSize ?? this.switchThumbSize,
    );
  }

  @override
  CalcTheme lerp(ThemeExtension<CalcTheme>? other, double t) {
    if (other is! CalcTheme) {
      return this;
    }

    return CalcTheme(
      systemWindow: Color.lerp(systemWindow, other.systemWindow, t)!,
      background: Color.lerp(background, other.background, t)!,
      borderDark: Color.lerp(borderDark, other.borderDark, t)!,
      text: Color.lerp(text, other.text, t)!,
      numbersText: Color.lerp(numbersText, other.numbersText, t)!,
      operatorsText: Color.lerp(operatorsText, other.operatorsText, t)!,
      functionsText: Color.lerp(functionsText, other.functionsText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
      unselected: Color.lerp(unselected, other.unselected, t)!,
      unselectedHover: Color.lerp(unselectedHover, other.unselectedHover, t)!,
      error: Color.lerp(error, other.error, t)!,
      displayLargeTextStyle: TextStyle.lerp(
        displayLargeTextStyle,
        other.displayLargeTextStyle,
        t,
      )!,
      displayMidTextStyle: TextStyle.lerp(
        displayMidTextStyle,
        other.displayMidTextStyle,
        t,
      )!,
      displaySmallTextStyle: TextStyle.lerp(
        displaySmallTextStyle,
        other.displaySmallTextStyle,
        t,
      )!,
      numButtonNumberTextStyle: TextStyle.lerp(
        numButtonNumberTextStyle,
        other.numButtonNumberTextStyle,
        t,
      )!,
      numButtonOperatorTextStyle: TextStyle.lerp(
        numButtonOperatorTextStyle,
        other.numButtonOperatorTextStyle,
        t,
      )!,
      numButtonFunctionTextStyle: TextStyle.lerp(
        numButtonFunctionTextStyle,
        other.numButtonFunctionTextStyle,
        t,
      )!,
      numButtonPressedTextStyle: TextStyle.lerp(
        numButtonPressedTextStyle,
        other.numButtonPressedTextStyle,
        t,
      )!,
      windowTitleTextStyle: TextStyle.lerp(
        windowTitleTextStyle,
        other.windowTitleTextStyle,
        t,
      )!,
      placeholderTextStyle: TextStyle.lerp(
        placeholderTextStyle,
        other.placeholderTextStyle,
        t,
      )!,
      optionIconButtonSize:
          Size.lerp(optionIconButtonSize, other.optionIconButtonSize, t)!,
      optionIconButtonPadding: EdgeInsetsGeometry.lerp(
        optionIconButtonPadding,
        other.optionIconButtonPadding,
        t,
      )!,
      optionIconSize: _lerpDouble(optionIconSize, other.optionIconSize, t),
      windowActionButtonSize:
          Size.lerp(windowActionButtonSize, other.windowActionButtonSize, t)!,
      windowActionBorderRadius: BorderRadius.lerp(
        windowActionBorderRadius,
        other.windowActionBorderRadius,
        t,
      )!,
      windowActionHoverColor: Color.lerp(
        windowActionHoverColor,
        other.windowActionHoverColor,
        t,
      )!,
      windowActionSplashColor: Color.lerp(
        windowActionSplashColor,
        other.windowActionSplashColor,
        t,
      )!,
      windowActionHighlightColor: Color.lerp(
        windowActionHighlightColor,
        other.windowActionHighlightColor,
        t,
      )!,
      basePadding: _lerpDouble(basePadding, other.basePadding, t),
      paddingSmall: _lerpDouble(paddingSmall, other.paddingSmall, t),
      itemSpacing: _lerpDouble(itemSpacing, other.itemSpacing, t),
      borderThickness: _lerpDouble(borderThickness, other.borderThickness, t),
      cardBorderRadius:
          _lerpDouble(cardBorderRadius, other.cardBorderRadius, t),
      windowBorderRadius:
          _lerpDouble(windowBorderRadius, other.windowBorderRadius, t),
      menuIndicatorHeight:
          _lerpDouble(menuIndicatorHeight, other.menuIndicatorHeight, t),
      backgroundShadow: Color.lerp(
        backgroundShadow,
        other.backgroundShadow,
        t,
      )!,
      settingsTitleTextStyle: TextStyle.lerp(
        settingsTitleTextStyle,
        other.settingsTitleTextStyle,
        t,
      )!,
      settingsCardTextStyle: TextStyle.lerp(
        settingsCardTextStyle,
        other.settingsCardTextStyle,
        t,
      )!,
      settingsCardValueTextStyle: TextStyle.lerp(
        settingsCardValueTextStyle,
        other.settingsCardValueTextStyle,
        t,
      )!,
      settingsCardAccentValueTextStyle: TextStyle.lerp(
        settingsCardAccentValueTextStyle,
        other.settingsCardAccentValueTextStyle,
        t,
      )!,
      tabTextStyle: TextStyle.lerp(tabTextStyle, other.tabTextStyle, t)!,
      themeCardTextStyle: TextStyle.lerp(
        themeCardTextStyle,
        other.themeCardTextStyle,
        t,
      )!,
      themeCardButtonTextStyle: TextStyle.lerp(
        themeCardButtonTextStyle,
        other.themeCardButtonTextStyle,
        t,
      )!,
      sliderTrackHeight:
          _lerpDouble(sliderTrackHeight, other.sliderTrackHeight, t),
      sliderThumbSize: _lerpDouble(sliderThumbSize, other.sliderThumbSize, t),
      switchTrackHeight:
          _lerpDouble(switchTrackHeight, other.switchTrackHeight, t),
      switchThumbSize: _lerpDouble(switchThumbSize, other.switchThumbSize, t),
    );
  }

  BoxDecoration get settingsCardDecoration => BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: backgroundShadow,
            offset: const Offset(0.5, 0.5),
            blurRadius: 0.5,
            spreadRadius: 0.5,
          ),
        ],
      );

  Color optionIconColor({
    required bool isActive,
    required bool isHovered,
    required bool isPressed,
    required bool usePressedAccent,
  }) {
    if (usePressedAccent && isPressed) {
      return accent;
    }
    if (isActive) {
      return accent;
    }
    if (isHovered) {
      return unselectedHover;
    }

    return unselected;
  }

  static CalcTheme _build({
    required Color systemWindow,
    required Color background,
    required Color borderDark,
    required Color text,
    required Color numbersText,
    required Color operatorsText,
    required Color functionsText,
    required Color accent,
    required Color accent2,
    required Color unselected,
    required Color unselectedHover,
    required Color error,
  }) {
    final displayLargeTextStyle = GoogleFonts.exo2(
      color: accent,
      fontSize: AppFontSizes.displayLarge(),
      fontWeight: FontWeight.w100,
      height: 1,
      letterSpacing: 0,
    );
    final displayMidTextStyle = GoogleFonts.exo2(
      color: accent,
      fontSize: AppFontSizes.displayMid(),
      fontWeight: FontWeight.w200,
      height: 1,
      letterSpacing: 0,
    );
    final displaySmallTextStyle = GoogleFonts.exo2(
      color: accent,
      fontSize: AppFontSizes.displaySmall(),
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: 0,
    );

    final numButtonBaseTextStyle = TextStyle(
      fontFamily: 'Exo',
      fontSize: AppFontSizes.button(),
      fontWeight: FontWeight.w100,
      height: 1,
      letterSpacing: 0,
    );

    return CalcTheme(
      systemWindow: systemWindow,
      background: background,
      borderDark: borderDark,
      text: text,
      numbersText: numbersText,
      operatorsText: operatorsText,
      functionsText: functionsText,
      accent: accent,
      accent2: accent2,
      unselected: unselected,
      unselectedHover: unselectedHover,
      error: error,
      displayLargeTextStyle: displayLargeTextStyle,
      displayMidTextStyle: displayMidTextStyle,
      displaySmallTextStyle: displaySmallTextStyle,
      numButtonNumberTextStyle:
          numButtonBaseTextStyle.copyWith(color: numbersText),
      numButtonOperatorTextStyle:
          numButtonBaseTextStyle.copyWith(color: operatorsText),
      numButtonFunctionTextStyle:
          numButtonBaseTextStyle.copyWith(color: functionsText),
      numButtonPressedTextStyle: numButtonBaseTextStyle.copyWith(color: accent),
      windowTitleTextStyle: TextStyle(
        color: text,
        fontFamily: 'Exo',
        fontSize: AppFontSizes.windowTitle(),
        fontWeight: FontWeight.w200,
        height: 1,
        letterSpacing: 0,
      ),
      placeholderTextStyle: TextStyle(
        color: text,
        fontFamily: 'Exo',
        fontSize: AppFontSizes.displayMid(),
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      optionIconButtonSize: const Size(24, 24),
      optionIconButtonPadding: EdgeInsets.zero,
      optionIconSize: 24,
      windowActionButtonSize: const Size(24, 24),
      windowActionBorderRadius: BorderRadius.circular(4),
      windowActionHoverColor: text.withValues(alpha: 0.08),
      windowActionSplashColor: text.withValues(alpha: 0.12),
      windowActionHighlightColor: text.withValues(alpha: 0.08),
      basePadding: AppDimens.basePadding,
      paddingSmall: AppDimens.paddingSmall,
      itemSpacing: AppDimens.itemSpacing,
      borderThickness: AppDimens.borderThickness,
      cardBorderRadius: AppDimens.cornerMedium,
      windowBorderRadius: 16,
      menuIndicatorHeight: 2,
      backgroundShadow: const Color(0x33000000),
      settingsTitleTextStyle: GoogleFonts.exo2(
        color: text,
        fontSize: 24,
        fontWeight: FontWeight.w200,
        height: 1,
        letterSpacing: 0,
      ),
      settingsCardTextStyle: GoogleFonts.exo2(
        color: text,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0,
      ),
      settingsCardValueTextStyle: GoogleFonts.exo2(
        color: unselected,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0,
      ),
      settingsCardAccentValueTextStyle: GoogleFonts.exo2(
        color: accent,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0,
      ),
      tabTextStyle: GoogleFonts.exo2(
        color: unselected,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0,
      ),
      themeCardTextStyle: GoogleFonts.exo2(
        color: accent,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0,
      ),
      themeCardButtonTextStyle: const TextStyle(
        fontFamily: 'Exo',
        fontSize: 8,
        fontWeight: FontWeight.w100,
        height: 1,
        letterSpacing: 0,
      ),
      sliderTrackHeight: 2,
      sliderThumbSize: 16,
      switchTrackHeight: 12,
      switchThumbSize: 16,
    );
  }

  static final CalcTheme _default = CalcTheme._build(
    systemWindow: AppDefaultColors.systemWindow,
    background: AppDefaultColors.background,
    borderDark: AppDefaultColors.borderDark,
    text: AppDefaultColors.text,
    numbersText: AppDefaultColors.numbersText,
    operatorsText: AppDefaultColors.operatorsText,
    functionsText: AppDefaultColors.functionsText,
    accent: AppDefaultColors.accent,
    accent2: AppDefaultColors.accent2,
    unselected: AppDefaultColors.unselected,
    unselectedHover: AppDefaultColors.unselectedHover,
    error: AppDefaultColors.error,
  );

  static final CalcTheme _themeOne = CalcTheme._build(
    systemWindow: AppThemeOneColors.systemWindow,
    background: AppThemeOneColors.background,
    borderDark: AppThemeOneColors.borderDark,
    text: AppThemeOneColors.text,
    numbersText: AppThemeOneColors.numbersText,
    operatorsText: AppThemeOneColors.operatorsText,
    functionsText: AppThemeOneColors.functionsText,
    accent: AppThemeOneColors.accent,
    accent2: AppThemeOneColors.accent2,
    unselected: AppThemeOneColors.unselected,
    unselectedHover: AppThemeOneColors.unselectedHover,
    error: AppThemeOneColors.error,
  );

  static final CalcTheme _themeTwo = CalcTheme._build(
    systemWindow: AppThemeTwoColors.systemWindow,
    background: AppThemeTwoColors.background,
    borderDark: AppThemeTwoColors.borderDark,
    text: AppThemeTwoColors.text,
    numbersText: AppThemeTwoColors.numbersText,
    operatorsText: AppThemeTwoColors.operatorsText,
    functionsText: AppThemeTwoColors.functionsText,
    accent: AppThemeTwoColors.accent,
    accent2: AppThemeTwoColors.accent2,
    unselected: AppThemeTwoColors.unselected,
    unselectedHover: AppThemeTwoColors.unselectedHover,
    error: AppThemeTwoColors.error,
  );
}

extension CalcThemeGetter on BuildContext {
  CalcTheme get calcTheme =>
      Theme.of(this).extension<CalcTheme>() ?? CalcTheme.fromThemeId(1);
}

double _lerpDouble(double begin, double end, double t) {
  return begin + (end - begin) * t;
}
