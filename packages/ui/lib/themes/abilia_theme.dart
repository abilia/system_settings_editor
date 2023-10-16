import 'package:flutter/material.dart';

import 'package:ui/themes/action_button/action_buttons_theme.dart';
import 'package:ui/themes/combobox/combobox_theme.dart';

const int _breakpointMobile = 360;

class AbiliaTheme extends ThemeExtension<AbiliaTheme> {
  final ActionButtonsTheme actionButtons;
  final ComboboxTheme combobox;

  const AbiliaTheme({
    required this.actionButtons,
    required this.combobox,
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
    actionButtons: ActionButtonsTheme.mobile,
    combobox: ComboboxTheme.medium(),
  );

  static final AbiliaTheme tablet = AbiliaTheme(
    actionButtons: ActionButtonsTheme.tablet,
    combobox: ComboboxTheme.medium(),
  );

  @override
  AbiliaTheme copyWith({
    ActionButtonsTheme? actionButtons,
    ComboboxTheme? combobox,
  }) {
    return AbiliaTheme(
      actionButtons: actionButtons ?? this.actionButtons,
      combobox: combobox ?? this.combobox,
    );
  }

  @override
  AbiliaTheme lerp(AbiliaTheme? other, double t) {
    if (other is! AbiliaTheme) return this;
    return AbiliaTheme(
      actionButtons: actionButtons.lerp(other.actionButtons, t),
      combobox: other.combobox,
    );
  }
}
