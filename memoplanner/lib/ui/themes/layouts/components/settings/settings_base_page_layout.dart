import 'package:flutter/material.dart';
import 'package:memoplanner/ui/themes/colors.dart';

class SettingsBasePageLayout {
  final DividerThemeData dividerThemeData;

  const SettingsBasePageLayout({
    this.dividerThemeData = const DividerThemeData(
      color: AbiliaColors.white120,
      thickness: 1,
      endIndent: 12,
    ),
  });
}

class SettingsBasePageLayoutMedium extends SettingsBasePageLayout {
  const SettingsBasePageLayoutMedium()
      : super(
          dividerThemeData: const DividerThemeData(
            color: AbiliaColors.white120,
            thickness: 2,
            endIndent: 24,
          ),
        );
}
