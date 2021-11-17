abstract class LayoutTheme {
  double get myPadding;
  double get secondPadding;
}

class GoTheme extends LayoutTheme {
  @override
  double get myPadding => 100;

  @override
  double get secondPadding => 16;
}

class MediumTheme extends GoTheme {
  @override
  double get secondPadding => 100;
}
