import 'package:flutter/material.dart';

import 'package:ui/themes/action_button/action_button_theme.dart';

const int _smallBreakpoint = 320;

extension ThemeExtention on BuildContext {
  AbiliaTheme get abiliaTheme =>
      Theme.of(this).extension<AbiliaTheme>() ?? AbiliaTheme.small;
}

class AbiliaTheme extends ThemeExtension<AbiliaTheme> {
  const AbiliaTheme({
    required this.actionButtonPrimary,
    required this.actionButtonSecondary,
    required this.actionButtonTertiary,
  });

  final ActionButtonPrimaryTheme actionButtonPrimary;
  final ActionButtonSecondaryTheme actionButtonSecondary;
  final ActionButtonTertiaryTheme actionButtonTertiary;

  static ThemeData getThemeData(double width) {
    if (width < _smallBreakpoint) {
      return ThemeData(
        visualDensity: VisualDensity.standard,
        extensions: [AbiliaTheme.small],
      );
    }
    return ThemeData(
      visualDensity: VisualDensity.standard,
      extensions: [AbiliaTheme.medium],
    );
  }

  static final AbiliaTheme small = AbiliaTheme(
    actionButtonPrimary: ActionButtonPrimaryTheme.small,
    actionButtonSecondary: ActionButtonSecondaryTheme.small,
    actionButtonTertiary: ActionButtonTertiaryTheme.small,
  );

  static final AbiliaTheme medium = AbiliaTheme(
    actionButtonPrimary: ActionButtonPrimaryTheme.medium,
    actionButtonSecondary: ActionButtonSecondaryTheme.medium,
    actionButtonTertiary: ActionButtonTertiaryTheme.medium,
  );

  @override
  AbiliaTheme copyWith({
    ActionButtonPrimaryTheme? actionButtonPrimary,
    ActionButtonSecondaryTheme? actionButtonSecondary,
    ActionButtonTertiaryTheme? actionButtonTertiary,
  }) {
    return AbiliaTheme(
      actionButtonPrimary: actionButtonPrimary ?? this.actionButtonPrimary,
      actionButtonSecondary:
          actionButtonSecondary ?? this.actionButtonSecondary,
      actionButtonTertiary: actionButtonTertiary ?? this.actionButtonTertiary,
    );
  }

  @override
  AbiliaTheme lerp(AbiliaTheme? other, double t) {
    if (other is! AbiliaTheme) return this;
    return AbiliaTheme(
      actionButtonPrimary:
          actionButtonPrimary.lerp(other.actionButtonPrimary, t),
      actionButtonSecondary:
          actionButtonSecondary.lerp(other.actionButtonSecondary, t),
      actionButtonTertiary:
          actionButtonTertiary.lerp(other.actionButtonTertiary, t),
    );
  }
}
