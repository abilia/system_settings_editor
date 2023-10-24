part of 'spinner_themes.dart';

class SeagullSpinnerTheme extends ThemeExtension<SeagullSpinnerTheme> {
  final double size;
  final double padding;
  final double thickness;

  const SeagullSpinnerTheme({
    required this.size,
    required this.padding,
    required this.thickness,
  });

  static const medium = SeagullSpinnerTheme(
    size: numerical500,
    padding: numerical2px,
    thickness: numerical2px,
  );

  static const large = SeagullSpinnerTheme(
    size: numerical700,
    padding: numerical4px,
    thickness: numerical5px,
  );

  @override
  SeagullSpinnerTheme copyWith({
    double? size,
    double? padding,
    double? thickness,
  }) {
    return SeagullSpinnerTheme(
      size: size ?? this.size,
      padding: padding ?? this.padding,
      thickness: thickness ?? this.thickness,
    );
  }

  @override
  SeagullSpinnerTheme lerp(SeagullSpinnerTheme? other, double t) {
    if (other is! SeagullSpinnerTheme) return this;
    return SeagullSpinnerTheme(
      size: lerpDouble(size, other.size, t) ?? size,
      padding: lerpDouble(padding, other.padding, t) ?? padding,
      thickness: lerpDouble(thickness, other.thickness, t) ?? thickness,
    );
  }
}
