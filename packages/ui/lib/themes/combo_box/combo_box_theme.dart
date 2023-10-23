part of 'combo_box_themes.dart';

class SeagullComboBoxTheme extends ThemeExtension<SeagullComboBoxTheme> {
  final InputDecorationTheme inputDecorationTheme;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;
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
    required this.helperBoxIconThemeDataSuccess,
    required this.inputBorderError,
    required this.inputBorderSuccess,
  });

  static final size800 = SeagullComboBoxTheme(
    inputDecorationTheme: textFieldInputTheme800,
    textStyle: AbiliaFonts.primary525.withColor(SurfaceColors.textPrimary),
    labelStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textSecondary),
    iconSize: numerical800,
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
    textStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textPrimary),
    iconSize: numerical600,
    padding: const EdgeInsets.symmetric(
      horizontal: numerical400,
      vertical: numerical500,
    ),
  );

  @override
  SeagullComboBoxTheme copyWith({
    InputDecorationTheme? inputDecorationTheme,
    TextStyle? textStyle,
    TextStyle? labelStyle,
    double? iconSize,
    BoxDecoration? boxDecoration,
    EdgeInsets? padding,
    BoxShadow? boxShadow,
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
      helperBoxIconThemeDataSuccess:
          helperBoxIconThemeDataSuccess ?? this.helperBoxIconThemeDataSuccess,
      inputBorderError: inputBorderError ?? this.inputBorderError,
      inputBorderSuccess: inputBorderSuccess ?? this.inputBorderSuccess,
    );
  }

  @override
  SeagullComboBoxTheme lerp(covariant SeagullComboBoxTheme? other, double t) {
    if (other is! SeagullComboBoxTheme) return this;
    return SeagullComboBoxTheme(
      iconSize: lerpDouble(iconSize, other.iconSize, t) ?? iconSize,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
      boxDecoration:
          boxDecoration.lerpTo(other.boxDecoration, t) ?? boxDecoration,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      boxShadow: BoxShadow.lerp(boxShadow, other.boxShadow, t) ?? boxShadow,
      inputDecorationTheme:
          inputDecorationTheme.merge(other.inputDecorationTheme),
      helperBoxIconThemeDataSuccess: IconThemeData.lerp(
          helperBoxIconThemeDataSuccess,
          other.helperBoxIconThemeDataSuccess,
          t),
      inputBorderError: other.inputBorderError,
      inputBorderSuccess: other.inputBorderSuccess,
    );
  }
}
