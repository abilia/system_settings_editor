import 'package:flutter/material.dart';

class AlarmSettingsPageLayout {
  final double playButtonSeparation;
  final EdgeInsets defaultPadding, topPadding, bottomPadding, dividerPadding;

  const AlarmSettingsPageLayout({
    this.playButtonSeparation = 12,
    this.defaultPadding = const EdgeInsets.fromLTRB(12, 12, 12, 0),
    this.topPadding = const EdgeInsets.fromLTRB(12, 12, 12, 0),
    this.bottomPadding = const EdgeInsets.fromLTRB(12, 12, 12, 64),
    this.dividerPadding = const EdgeInsets.only(top: 16, bottom: 8),
  });
}

class AlarmSettingsPageLayoutMedium extends AlarmSettingsPageLayout {
  const AlarmSettingsPageLayoutMedium()
      : super(
          playButtonSeparation: 16,
          defaultPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          topPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          bottomPadding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          dividerPadding: const EdgeInsets.only(top: 24, bottom: 16),
        );
}
