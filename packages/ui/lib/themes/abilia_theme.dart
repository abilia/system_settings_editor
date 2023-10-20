import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_color_themes.dart';
import 'package:ui/themes/abilia_spacing_themes.dart';
import 'package:ui/themes/abilia_text_style_themes.dart';
import 'package:ui/themes/buttons/action_button/action_button_themes.dart';
import 'package:ui/themes/buttons/icon_button/icon_button_themes.dart';
import 'package:ui/themes/combo_box/combo_box_theme.dart';
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
  final SeagullTagThemes tags;
  final SeagullSpinnerThemes spinners;
  final AbiliaColorThemes colors;
  final AbiliaTextStyleThemes textStyles;
  final AbiliaSpacingThemes spacings;
  final SeagullComboBoxTheme comboBox;

  const AbiliaTheme({
    required this.actionButtons,
    required this.iconButtons,
    required this.helperBox,
    required this.tags,
    required this.spinners,
    required this.comboBox,
    required this.colors,
    required this.textStyles,
    required this.spacings,
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
    colors: AbiliaColorThemes.colors,
    tags: SeagullTagThemes.tags,
    spinners: SeagullSpinnerThemes.spinners,
    textStyles: AbiliaTextStyleThemes.textStyles,
    spacings: AbiliaSpacingThemes.spacings,
    comboBox: SeagullComboBoxTheme.medium(),
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
    comboBox: SeagullComboBoxTheme.large(),
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
    SeagullTagThemes? tags,
    SeagullSpinnerThemes? spinners,
    SeagullComboBoxTheme? comboBox,
    AbiliaColorThemes? colors,
    AbiliaTextStyleThemes? textStyles,
    AbiliaSpacingThemes? spacings,
  }) {
    return AbiliaTheme(
      actionButtons: actionButtons ?? this.actionButtons,
      iconButtons: iconButtons ?? this.iconButtons,
      helperBox: helperBox ?? this.helperBox,
      tags: tags ?? this.tags,
      spinners: spinners ?? this.spinners,
      comboBox: comboBox ?? this.comboBox,
      colors: colors ?? this.colors,
      textStyles: textStyles ?? this.textStyles,
      spacings: spacings ?? this.spacings,
    );
  }

  @override
  AbiliaTheme lerp(AbiliaTheme? other, double t) {
    if (other is! AbiliaTheme) return this;
    return AbiliaTheme(
      actionButtons: actionButtons.lerp(other.actionButtons, t),
      iconButtons: iconButtons.lerp(other.iconButtons, t),
      helperBox: helperBox.lerp(other.helperBox, t),
      tags: tags.lerp(other.tags, t),
      spinners: spinners.lerp(other.spinners, t),
      comboBox: comboBox.lerp(other.comboBox, t),
      colors: colors.lerp(other.colors, t),
      textStyles: textStyles.lerp(other.textStyles, t),
      spacings: spacings.lerp(other.spacings, t),
    );
  }
}
