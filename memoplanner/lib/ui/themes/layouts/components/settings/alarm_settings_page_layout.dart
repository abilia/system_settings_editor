import 'package:flutter/material.dart';

class AlarmSettingsPageLayout {
  final double playButtonSeparation;
  final EdgeInsets dividerPadding;

  const AlarmSettingsPageLayout({
    this.playButtonSeparation = 12,
    this.dividerPadding = const EdgeInsets.only(top: 16, bottom: 8),
  });
}

class AlarmSettingsPageLayoutMedium extends AlarmSettingsPageLayout {
  const AlarmSettingsPageLayoutMedium()
      : super(
          playButtonSeparation: 16,
          dividerPadding: const EdgeInsets.only(top: 24, bottom: 16),
        );
}
