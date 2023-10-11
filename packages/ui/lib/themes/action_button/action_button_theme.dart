import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/numericals.dart';

part 'action_button_primary_theme.dart';

part 'action_button_secondary_theme.dart';

part 'action_button_tertiary_theme.dart';

sealed class ActionButtonTheme extends ThemeExtension<ActionButtonTheme> {
  final double iconSpacing;
  final ButtonStyle buttonStyle;

  const ActionButtonTheme({
    required this.iconSpacing,
    required this.buttonStyle,
  });
}
