import 'package:flutter/material.dart';

class SettingsBasePageLayout {
  final DividerThemeData dividerThemeData;

  const SettingsBasePageLayout({
    this.dividerThemeData = const DividerThemeData(
      thickness: 1,
      endIndent: 12,
    ),
  });
}

class SettingsBasePageLayoutMedium extends SettingsBasePageLayout {
  const SettingsBasePageLayoutMedium()
      : super(
          dividerThemeData: const DividerThemeData(
            thickness: 2,
            endIndent: 24,
          ),
        );
}
