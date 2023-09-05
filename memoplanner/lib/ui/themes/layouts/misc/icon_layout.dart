class IconLayout {
  final double tiny,
      small,
      smaller,
      button,
      normal,
      large,
      huge,
      doubleIconTop,
      doubleIconLeft;

  const IconLayout({
    this.tiny = 20,
    this.small = 24,
    this.smaller = 32,
    this.button = 28,
    this.normal = 32,
    this.large = 48,
    this.huge = 96,
    this.doubleIconTop = 20,
    this.doubleIconLeft = 32,
  });
}

class IconLayoutMedium extends IconLayout {
  const IconLayoutMedium()
      : super(
          tiny: 30,
          smaller: 32,
          small: 36,
          button: 42,
          normal: 64,
          large: 96,
          huge: 192,
          doubleIconTop: 30,
          doubleIconLeft: 48,
        );
}
