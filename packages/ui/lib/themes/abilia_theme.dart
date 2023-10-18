import 'package:flutter/material.dart';

import 'package:ui/themes/action_button/action_buttons_theme.dart';
import 'package:ui/themes/combo_box/combo_box_theme.dart';

const int _breakpointMobile = 360;

class AbiliaTheme extends ThemeExtension<AbiliaTheme> {
  final ActionButtonsTheme actionButton;
  final SeagullComoBoxTheme comboBox;

  const AbiliaTheme({
    required this.actionButton,
    required this.comboBox,
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
    actionButton: ActionButtonsTheme.mobile,
    comboBox: SeagullComoBoxTheme.medium(),
  );

  static final AbiliaTheme tablet = AbiliaTheme(
    actionButton: ActionButtonsTheme.tablet,
    comboBox: SeagullComoBoxTheme.medium(),
  );

  @override
  AbiliaTheme copyWith({
    ActionButtonsTheme? actionButton,
    SeagullComoBoxTheme? comboBox,
  }) {
    return AbiliaTheme(
      actionButton: actionButton ?? this.actionButton,
      comboBox: comboBox ?? this.comboBox,
    );
  }

  @override
  AbiliaTheme lerp(AbiliaTheme? other, double t) {
    if (other is! AbiliaTheme) return this;
    return AbiliaTheme(
      actionButton: actionButton.lerp(other.actionButton, t),
      comboBox: other.comboBox,
    );
  }
}
