import 'package:flutter/material.dart';

import 'package:ui/themes/action_button/action_buttons_theme.dart';
import 'package:ui/themes/combobox/combobox_theme.dart';

const int _breakpointMobile = 360;

class AbiliaTheme extends ThemeExtension<AbiliaTheme> {
  final ActionButtonsTheme actionButtonsTheme;
  final ComboboxTheme comboboxTheme;

  const AbiliaTheme({
    required this.actionButtonsTheme,
    required this.comboboxTheme,
  });

  factory AbiliaTheme.of(BuildContext context) =>
      Theme.of(context).extension<AbiliaTheme>() ?? AbiliaTheme.mobile;

  static ThemeData getThemeData(double width) {
    if (width < _breakpointMobile) {
      return ThemeData(
        visualDensity: VisualDensity.standard,
        extensions: [AbiliaTheme.mobile],
      );
    }
    return ThemeData(
      visualDensity: VisualDensity.standard,
      extensions: [AbiliaTheme.tablet],
    );
  }

  static final AbiliaTheme mobile = AbiliaTheme(
    actionButtonsTheme: ActionButtonsTheme.mobile,
    comboboxTheme: ComboboxTheme.medium(),
  );

  static final AbiliaTheme tablet = AbiliaTheme(
    actionButtonsTheme: ActionButtonsTheme.tablet,
    comboboxTheme: ComboboxTheme.medium(),
  );

  @override
  AbiliaTheme copyWith({
    ActionButtonsTheme? actionButtonsTheme,
    ComboboxTheme? comboboxTheme,
  }) {
    return AbiliaTheme(
      actionButtonsTheme: actionButtonsTheme ?? this.actionButtonsTheme,
      comboboxTheme: comboboxTheme ?? this.comboboxTheme,
    );
  }

  @override
  AbiliaTheme lerp(AbiliaTheme? other, double t) {
    if (other is! AbiliaTheme) return this;
    return AbiliaTheme(
      actionButtonsTheme: actionButtonsTheme.lerp(other.actionButtonsTheme, t),
      comboboxTheme: other.comboboxTheme,
    );
  }
}
