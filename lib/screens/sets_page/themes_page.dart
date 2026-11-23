import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../providers/theme_settings_provider.dart';
import '../../providers/window_layout_provider.dart';
import '../../utils/styles/dimensions/dimensions.dart';
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
          spacing: calcTheme.itemSpacing,
          children: [
            if (showTransparency) ...[
              Text(
                context.tr('settings.transparency'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: calcTheme.settingsTitleTextStyle,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.mobileItemSpacing,
                  ),
                  child: Column(
                    spacing: AppDimens.mobileItemSpacing,
                    children: [
                      SettingsCard(
                        title: context.tr('settings.blur'),
                        value: themeSettings.backgroundBlur > 0
                            ? context.tr('settings.on')
                            : context.tr('settings.off'),
                        valueColor: themeSettings.backgroundBlur > 0
                            ? calcTheme.accent
                            : calcTheme.unselected,
                        axis: SettingsCardAxis.horizontal,
                        child: _CalcSwitch(
                          value: themeSettings.backgroundBlur > 0,
                          onChanged: themeSettings.setBackgroundBlur,
                        ),
                      ),
                      SettingsCard(
                        title: context.tr('settings.opacity'),
                        value: themeSettings.backgroundOpacity.toStringAsFixed(
                          1,
                        ),
                        valueIsAccent: true,
                        child: _CalcSlider(
                          value: themeSettings.backgroundOpacity,
                          onChanged: themeSettings.setBackgroundOpacity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                context.tr('settings.themes'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: calcTheme.settingsTitleTextStyle,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.mobileItemSpacing,
              ),
              child: _ThemeCards(
                themes: themeSettings.themesList,
                selectedTheme: themeSettings.currentTheme,
                isExpandedDesktop: isExpandedDesktop,
                onThemeSelected: themeSettings.setCurrentTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCards extends StatelessWidget {
  const _ThemeCards({
    required this.themes,
    required this.selectedTheme,
    required this.isExpandedDesktop,
    required this.onThemeSelected,
  });

  final List<int> themes;
  final int selectedTheme;
  final bool isExpandedDesktop;
  final ValueChanged<int> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    const gap = AppDimens.mobileItemSpacing;
    if (SystemHelper.isMobileSystem) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: ThemeCard.figmaAspectRatio,
        ),
        itemCount: themes.length,
        itemBuilder: (context, index) => _card(themes[index]),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredColumns = isExpandedDesktop ? 6 : 3;
        final availableWidth = constraints.maxWidth + gap;
        final width = math.max(0.0, availableWidth / preferredColumns - gap);
        final cardWidth = isExpandedDesktop ? math.min(width, 130.0) : width;

        return Wrap(
          direction: Axis.horizontal,
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final themeId in themes)
              SizedBox(width: cardWidth, child: _card(themeId)),
          ],
        );
      },
    );
  }

  ThemeCard _card(int themeId) => ThemeCard(
    themeId: themeId,
    isSelected: themeId == selectedTheme,
    onTap: () => onThemeSelected(themeId),
  );
}

class _CalcSlider extends StatelessWidget {
  const _CalcSlider({Key? key, required this.value, required this.onChanged})
    : super(key: key);

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
  const _CalcSwitch({Key? key, required this.value, required this.onChanged})
    : super(key: key);

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
                borderRadius: BorderRadius.circular(
                  calcTheme.windowBorderRadius,
                ),
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
