import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'dimensions/font_sizes.dart';

final ThemeData calcTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Colors.transparent,
  ),
  canvasColor: Colors.transparent,
  cardColor: Colors.transparent,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.transparent,
  textTheme: TextTheme(
    displayLarge: GoogleFonts.exo2(
      color: AppColors.accent,
      fontSize: AppFontSizes.displayLargeFontSize,
      fontWeight: FontWeight.w100,
      height: 1,
      letterSpacing: 0,
    ),
    displayMedium: GoogleFonts.exo2(
      color: AppColors.accent,
      fontSize: AppFontSizes.displayMidFontSize,
      fontWeight: FontWeight.w100,
      height: 1,
      letterSpacing: 0,
    ),
    displaySmall: GoogleFonts.exo2(
      color: AppColors.accent,
      fontSize: AppFontSizes.displaySmallFontSize,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: 0,
    ),
  ),
);
