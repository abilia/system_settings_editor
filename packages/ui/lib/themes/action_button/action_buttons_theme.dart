import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/numericals.dart';

part 'action_button_primary_theme.dart';

part 'action_button_secondary_theme.dart';

part 'action_button_tertiary_theme.dart';

part 'action_button_theme.dart';

class ActionButtonsTheme extends ThemeExtension<ActionButtonsTheme> {
  final ActionButtonTheme primarySmall;
  final ActionButtonTheme secondarySmall;
  final ActionButtonTheme tertiarySmall;
  final ActionButtonTheme primaryMedium;
  final ActionButtonTheme secondaryMedium;
  final ActionButtonTheme tertiaryMedium;
  final ActionButtonTheme primaryLarge;
  final ActionButtonTheme secondaryLarge;
  final ActionButtonTheme tertiaryLarge;

  const ActionButtonsTheme({
    required this.primarySmall,
    required this.secondarySmall,
    required this.tertiarySmall,
    required this.primaryMedium,
    required this.secondaryMedium,
    required this.tertiaryMedium,
    required this.primaryLarge,
    required this.secondaryLarge,
    required this.tertiaryLarge,
  });

  static final ActionButtonsTheme mobile = ActionButtonsTheme(
    primarySmall: ActionButtonPrimaryTheme.small,
    secondarySmall: ActionButtonSecondaryTheme.small,
    tertiarySmall: ActionButtonTertiaryTheme.small,
    primaryMedium: ActionButtonPrimaryTheme.medium,
    secondaryMedium: ActionButtonSecondaryTheme.medium,
    tertiaryMedium: ActionButtonTertiaryTheme.medium,
    primaryLarge: ActionButtonPrimaryTheme.medium,
    secondaryLarge: ActionButtonSecondaryTheme.medium,
    tertiaryLarge: ActionButtonTertiaryTheme.medium,
  );

  static final ActionButtonsTheme tablet = mobile;

  @override
  ActionButtonsTheme copyWith({
    ActionButtonPrimaryTheme? primarySmall,
    ActionButtonSecondaryTheme? secondarySmall,
    ActionButtonTertiaryTheme? tertiarySmall,
    ActionButtonPrimaryTheme? primaryMedium,
    ActionButtonSecondaryTheme? secondaryMedium,
    ActionButtonTertiaryTheme? tertiaryMedium,
    ActionButtonPrimaryTheme? primaryLarge,
    ActionButtonSecondaryTheme? secondaryLarge,
    ActionButtonTertiaryTheme? tertiaryLarge,
  }) {
    return ActionButtonsTheme(
      primarySmall: primarySmall ?? this.primarySmall,
      secondarySmall: secondarySmall ?? this.secondarySmall,
      tertiarySmall: tertiarySmall ?? this.tertiarySmall,
      primaryMedium: primaryMedium ?? this.primaryMedium,
      secondaryMedium: secondaryMedium ?? this.secondaryMedium,
      tertiaryMedium: tertiaryMedium ?? this.tertiaryMedium,
      primaryLarge: primaryLarge ?? this.primaryLarge,
      secondaryLarge: secondaryLarge ?? this.secondaryLarge,
      tertiaryLarge: tertiaryLarge ?? this.tertiaryLarge,
    );
  }

  @override
  ActionButtonsTheme lerp(ActionButtonsTheme? other, double t) {
    if (other is! ActionButtonsTheme) return this;
    return ActionButtonsTheme(
      primarySmall: primarySmall.lerp(other.primarySmall, t),
      secondarySmall: secondarySmall.lerp(other.secondarySmall, t),
      tertiarySmall: tertiarySmall.lerp(other.tertiarySmall, t),
      primaryMedium: primaryMedium.lerp(other.primaryMedium, t),
      secondaryMedium: secondaryMedium.lerp(other.secondaryMedium, t),
      tertiaryMedium: tertiaryMedium.lerp(other.tertiaryMedium, t),
      primaryLarge: primaryLarge.lerp(other.primaryLarge, t),
      secondaryLarge: secondaryLarge.lerp(other.secondaryLarge, t),
      tertiaryLarge: tertiaryLarge.lerp(other.tertiaryLarge, t),
    );
  }
}
