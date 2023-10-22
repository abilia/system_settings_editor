part of 'combo_box_themes.dart';

class SeagullComboBoxTheme extends ThemeExtension<SeagullComboBoxTheme> {
  final InputDecorationTheme inputDecorationTheme;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;
  final IconThemeData helperBoxIconThemeDataError;
  final IconThemeData helperBoxIconThemeDataSuccess;
  final OutlineInputBorder inputBorderError;
  final OutlineInputBorder inputBorderSuccess;
  final BoxDecoration boxDecoration;
  final BoxShadow boxShadow;

  const SeagullComboBoxTheme({
    required this.inputDecorationTheme,
    required this.labelStyle,
    required this.textStyle,
    required this.padding,
    required this.iconSize,
    required this.boxDecoration,
    required this.boxShadow,
    required this.helperBoxIconThemeDataError,
    required this.helperBoxIconThemeDataSuccess,
    required this.inputBorderError,
    required this.inputBorderSuccess,
  });

  static final size800 = SeagullComboBoxTheme(
    inputDecorationTheme: textFieldInputTheme800,
    textStyle:
        AbiliaFonts.primary525.copyWith(color: SurfaceColors.textPrimary),
    labelStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textSecondary),
    iconSize: numerical800,
    helperBoxIconThemeDataError: iconThemeDataError,
    helperBoxIconThemeDataSuccess: iconThemeDataSuccess,
    inputBorderError: errorBorder,
    inputBorderSuccess: successBorder,
    padding: const EdgeInsets.symmetric(
      horizontal: numerical400,
      vertical: numerical300,
    ),
    boxDecoration: textFieldBoxDecoration,
    boxShadow: const BoxShadow(
      color: Color(0xFFD5D7F5),
      spreadRadius: numerical200,
    ),
  );

  static final size700 = size800.copyWith(
    inputDecorationTheme: textFieldInputTheme700,
    textStyle:
        AbiliaFonts.primary425.copyWith(color: SurfaceColors.textPrimary),
    iconSize: numerical600,
    padding: const EdgeInsets.symmetric(
      horizontal: numerical400,
      vertical: numerical500,
    ),
    messagePadding: const EdgeInsets.all(numerical300),
  );

  @override
  SeagullComboBoxTheme copyWith({
    InputDecorationTheme? inputDecorationTheme,
    TextStyle? textStyle,
    TextStyle? labelStyle,
    Widget? leading,
    Widget? trailing,
    bool? obscureText,
    double? iconSize,
    EdgeInsets? messagePadding,
    double? iconGap,
    BoxDecoration? boxDecoration,
    EdgeInsets? padding,
    BoxShadow? boxShadow,
    IconThemeData? helperBoxIconThemeDataError,
    IconThemeData? helperBoxIconThemeDataSuccess,
    OutlineInputBorder? inputBorderError,
    OutlineInputBorder? inputBorderSuccess,
  }) {
    return SeagullComboBoxTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      textStyle: textStyle ?? this.textStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      iconSize: iconSize ?? this.iconSize,
      boxDecoration: boxDecoration ?? this.boxDecoration,
      boxShadow: boxShadow ?? this.boxShadow,
      padding: padding ?? this.padding,
      helperBoxIconThemeDataError:
          helperBoxIconThemeDataError ?? this.helperBoxIconThemeDataError,
      helperBoxIconThemeDataSuccess:
          helperBoxIconThemeDataSuccess ?? this.helperBoxIconThemeDataSuccess,
      inputBorderError: inputBorderError ?? this.inputBorderError,
      inputBorderSuccess: inputBorderSuccess ?? this.inputBorderSuccess,
    );
  }

  @override
  SeagullComboBoxTheme lerp(covariant SeagullComboBoxTheme? other, double t) {
    return copyWith(
      iconSize: lerpDouble(iconSize, other?.iconSize, t),
      textStyle: TextStyle.lerp(textStyle, other?.textStyle, t),
      labelStyle: TextStyle.lerp(labelStyle, other?.labelStyle, t),
      boxDecoration: boxDecoration.lerpTo(other?.boxDecoration, t),
      padding: EdgeInsets.lerp(padding, other?.padding, t),
    );
  }
}
