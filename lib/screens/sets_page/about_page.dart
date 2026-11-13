import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/styles/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(calcTheme.basePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: calcTheme.backgroundShadow,
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/app logo.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: calcTheme.paddingSmall),
            Text(
              '3IXCALC',
              style: GoogleFonts.audiowide(
                color: calcTheme.text,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: calcTheme.paddingSmall),
            Text('1.2.0', style: calcTheme.settingsCardValueTextStyle),
          ],
        ),
      ),
    );
  }
}
