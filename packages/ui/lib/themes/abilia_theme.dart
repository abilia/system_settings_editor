import 'package:flutter/material.dart';
import 'package:ui/themes/buttons/action_button/action_button_themes.dart';
import 'package:ui/themes/buttons/icon_button/icon_button_themes.dart';
import 'package:ui/themes/helper_box/helper_box_themes.dart';
import 'package:ui/themes/spinner/spinner_themes.dart';
import 'package:ui/themes/tag/tag_themes.dart';

const int _breakpointMobile = 640;
const int _breakpointTablet = 1280;
const int _breakpointDesktop = 1600;

class AbiliaTheme extends ThemeExtension<AbiliaTheme> {
  final SeagullActionButtonThemes actionButtons;
  final SeagullIconButtonThemes iconButtons;
  final SeagullHelperBoxThemes helperBox;
  final SeagullSpinnerThemes spinner;
  final SeagullTagThemes tag;

  const AbiliaTheme({
    required this.actionButtons,
    required this.iconButtons,
    required this.helperBox,
    required this.spinner,
    required this.tag,
  });

  factory AbiliaTheme.of(BuildContext context) =>
      Theme.of(context).extension<AbiliaTheme>() ?? AbiliaTheme.mobile;

  static ThemeData getThemeData(double width) {
    final abiliaTheme = _getAbiliaTheme(width);
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      extensions: [abiliaTheme],
    );
  }

  static AbiliaTheme _getAbiliaTheme(double width) {
    if (width < _breakpointMobile) {
      return AbiliaTheme.mobile;
    }
    if (width < _breakpointTablet) {
      return AbiliaTheme.tablet;
    }
    if (width < _breakpointDesktop) {
      return AbiliaTheme.desktopSmall;
    }
    return AbiliaTheme.desktopLarge;
  }

  static final AbiliaTheme mobile = AbiliaTheme(
    actionButtons: SeagullActionButtonThemes.mobile,
    iconButtons: SeagullIconButtonThemes.mobile,
    helperBox: SeagullHelperBoxThemes.mobile,
    spinner: SeagullSpinnerThemes.themes,
    tag: SeagullTagThemes.themes,
  );

  static final AbiliaTheme tablet = mobile.copyWith(
    actionButtons: SeagullActionButtonThemes.tablet,
    iconButtons: SeagullIconButtonThemes.tablet,
    helperBox: SeagullHelperBoxThemes.tablet,
  );

  static final AbiliaTheme desktopSmall = tablet.copyWith(
    actionButtons: SeagullActionButtonThemes.desktopSmall,
    iconButtons: SeagullIconButtonThemes.desktopSmall,
    helperBox: SeagullHelperBoxThemes.desktopSmall,
  );

  static final AbiliaTheme desktopLarge = desktopSmall.copyWith(
    actionButtons: SeagullActionButtonThemes.desktopLarge,
    iconButtons: SeagullIconButtonThemes.desktopLarge,
    helperBox: SeagullHelperBoxThemes.desktopLarge,
  );

  @override
  AbiliaTheme copyWith({
    SeagullActionButtonThemes? actionButtons,
    SeagullIconButtonThemes? iconButtons,
    SeagullHelperBoxThemes? helperBox,
    SeagullSpinnerThemes? spinner,
    SeagullTagThemes? tag,
  }) {
    return AbiliaTheme(
      actionButtons: actionButtons ?? this.actionButtons,
      iconButtons: iconButtons ?? this.iconButtons,
      helperBox: helperBox ?? this.helperBox,
      spinner: spinner ?? this.spinner,
      tag: tag ?? this.tag,
    );
  }

  @override
  AbiliaTheme lerp(AbiliaTheme? other, double t) {
    if (other is! AbiliaTheme) return this;
    return AbiliaTheme(
      actionButtons: actionButtons.lerp(other.actionButtons, t),
      iconButtons: iconButtons.lerp(other.iconButtons, t),
      helperBox: helperBox.lerp(other.helperBox, t),
      spinner: spinner.lerp(other.spinner, t),
      tag: tag.lerp(other.tag, t),
    );
  }
}
