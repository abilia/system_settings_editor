part of 'combo_box_themes.dart';

class SeagullComboBoxTheme extends ThemeExtension<SeagullComboBoxTheme> {
  final InputDecorationTheme inputDecorationTheme;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;
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
  });

  static final size800 = SeagullComboBoxTheme(
    inputDecorationTheme: textFieldInputThemeLarge,
    textStyle:
        AbiliaFonts.primary525.copyWith(color: SurfaceColors.textPrimary),
    labelStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textSecondary),
    iconSize: numerical800,
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
    inputDecorationTheme: textFieldInputThemeMedium,
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
  }) {
    return SeagullComboBoxTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      textStyle: textStyle ?? this.textStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      iconSize: iconSize ?? this.iconSize,
      boxDecoration: boxDecoration ?? this.boxDecoration,
      boxShadow: boxShadow ?? this.boxShadow,
      padding: padding ?? this.padding,
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
