part of 'combo_box_themes.dart';

class SeagullComboBoxTheme extends ThemeExtension<SeagullComboBoxTheme> {
  final InputDecorationTheme inputDecorationTheme;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final IconThemeData iconThemeData;
  final IconThemeData helperBoxIconThemeDataSuccess;
  final OutlineInputBorder inputBorderError;
  final OutlineInputBorder inputBorderSuccess;
  final BoxDecoration boxDecoration;
  final BoxDecoration boxDecorationSelected;

  const SeagullComboBoxTheme({
    required this.inputDecorationTheme,
    required this.labelStyle,
    required this.textStyle,
    required this.padding,
    required this.boxDecoration,
    required this.boxDecorationSelected,
    required this.iconThemeData,
    required this.helperBoxIconThemeDataSuccess,
    required this.inputBorderError,
    required this.inputBorderSuccess,
  });

  static final size800 = SeagullComboBoxTheme(
    inputDecorationTheme: textFieldInputTheme800,
    textStyle: AbiliaFonts.primary525.withColor(SurfaceColors.textPrimary),
    labelStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textSecondary),
    iconThemeData: comboBoxIconThemeData800,
    helperBoxIconThemeDataSuccess: iconThemeDataSuccess,
    inputBorderError: errorBorder,
    inputBorderSuccess: successBorder,
    padding: const EdgeInsets.symmetric(
      horizontal: numerical400,
      vertical: numerical300,
    ),
    boxDecoration: textFieldBoxDecoration,
    boxDecorationSelected: textFieldBoxDecorationSelected,
  );

  static final size700 = size800.copyWith(
    inputDecorationTheme: textFieldInputTheme700,
    textStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textPrimary),
    iconThemeData: comboBoxIconThemeData700,
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
    IconThemeData? iconThemeData,
    BoxDecoration? boxDecoration,
    BoxDecoration? boxDecorationSelected,
    EdgeInsets? padding,
    IconThemeData? helperBoxIconThemeDataSuccess,
    OutlineInputBorder? inputBorderError,
    OutlineInputBorder? inputBorderSuccess,
  }) {
    return SeagullComboBoxTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      textStyle: textStyle ?? this.textStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      iconThemeData: iconThemeData ?? this.iconThemeData,
      boxDecoration: boxDecoration ?? this.boxDecoration,
      boxDecorationSelected:
          boxDecorationSelected ?? this.boxDecorationSelected,
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
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
      boxDecoration:
          boxDecoration.lerpTo(other.boxDecoration, t) ?? boxDecoration,
      boxDecorationSelected:
          boxDecorationSelected.lerpTo(other.boxDecorationSelected, t) ??
              boxDecorationSelected,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      inputDecorationTheme:
          inputDecorationTheme.merge(other.inputDecorationTheme),
      iconThemeData: IconThemeData.lerp(iconThemeData, other.iconThemeData, t),
      helperBoxIconThemeDataSuccess: IconThemeData.lerp(
        helperBoxIconThemeDataSuccess,
        other.helperBoxIconThemeDataSuccess,
        t,
      ),
      inputBorderError: other.inputBorderError,
      inputBorderSuccess: other.inputBorderSuccess,
    );
  }
}
