import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_settings_provider.dart';
import '../../providers/window_layout_provider.dart';
import '../../utils/system/system_helper.dart';
import '../../utils/styles/theme.dart';
import '../../widgets/cards/settings_card.dart';
import '../../widgets/cards/theme_card.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final themeSettings = context.watch<ThemeSettingsProvider>();
    final windowLayout = context.watch<WindowLayoutProvider>();
    final showTransparency = !SystemHelper.isMobileSystem;
    final isExpandedDesktop =
        !SystemHelper.isMobileSystem && windowLayout.isExpanded;

    return SingleChildScrollView(
      padding: EdgeInsets.all(calcTheme.basePadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTransparency) ...[
              Text(
                'transparency',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: calcTheme.settingsTitleTextStyle,
              ),
              SizedBox(height: calcTheme.itemSpacing),
              SettingsCard(
                title: 'blur',
                value: themeSettings.backgroundBlur > 0 ? 'on' : 'off',
                valueColor: themeSettings.backgroundBlur > 0
                    ? calcTheme.accent
                    : calcTheme.unselected,
                axis: SettingsCardAxis.horizontal,
                isExpanded: isExpandedDesktop,
                child: _CalcSwitch(
                  value: themeSettings.backgroundBlur > 0,
                  onChanged: themeSettings.setBackgroundBlur,
                ),
              ),
              const SizedBox(height: 10),
              SettingsCard(
                title: 'opacity',
                value: themeSettings.backgroundOpacity.toStringAsFixed(1),
                valueIsAccent: true,
                isExpanded: isExpandedDesktop,
                child: _CalcSlider(
                  value: themeSettings.backgroundOpacity,
                  onChanged: themeSettings.setBackgroundOpacity,
                ),
              ),
              SizedBox(height: calcTheme.itemSpacing),
            ],
            Text(
              'themes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: calcTheme.settingsTitleTextStyle,
            ),
            SizedBox(height: calcTheme.itemSpacing),
            _ThemesGrid(
              themes: themeSettings.themesList,
              selectedTheme: themeSettings.currentTheme,
              isExpandedDesktop: isExpandedDesktop,
              onThemeSelected: themeSettings.setCurrentTheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemesGrid extends StatelessWidget {
  const _ThemesGrid({
    Key? key,
    required this.themes,
    required this.selectedTheme,
    required this.isExpandedDesktop,
    required this.onThemeSelected,
  }) : super(key: key);

  final List<int> themes;
  final int selectedTheme;
  final bool isExpandedDesktop;
  final ValueChanged<int> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpandedDesktop ? 82 * 6 + 10 * 5 : 82 * 2 + 10,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isExpandedDesktop ? 6 : 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: ThemeCard.figmaAspectRatio,
        ),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final themeId = themes[index];

          return ThemeCard(
            themeId: themeId,
            isSelected: themeId == selectedTheme,
            onTap: () => onThemeSelected(themeId),
          );
        },
      ),
    );
  }
}

class _CalcSlider extends StatelessWidget {
  const _CalcSlider({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return SizedBox(
      width: double.infinity,
      height: 24,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: calcTheme.sliderTrackHeight,
          activeTrackColor: calcTheme.accent,
          inactiveTrackColor: calcTheme.unselected,
          thumbColor: calcTheme.text,
          overlayColor: Colors.transparent,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: calcTheme.sliderThumbSize / 2,
          ),
          overlayShape: SliderComponentShape.noOverlay,
        ),
        child: Slider(
          value: value,
          min: 0,
          max: 1,
          divisions: 5,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CalcSwitch extends StatelessWidget {
  const _CalcSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: 32,
        height: calcTheme.switchThumbSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: calcTheme.switchTrackHeight,
              decoration: BoxDecoration(
                color: value ? calcTheme.accent : calcTheme.background,
                borderRadius:
                    BorderRadius.circular(calcTheme.windowBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: calcTheme.backgroundShadow,
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: calcTheme.switchThumbSize,
                height: calcTheme.switchThumbSize,
                decoration: BoxDecoration(
                  color: calcTheme.text,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
