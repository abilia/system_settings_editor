class ClockLayout {
  final double height,
      width,
      borderWidth,
      centerPointRadius,
      hourNumberScale,
      hourHandLength,
      minuteHandLength,
      hourHandWidth,
      minuteHandWidth,
      fontSize;

  const ClockLayout({
    this.height = 60,
    this.width = 48,
    this.borderWidth = 1,
    this.centerPointRadius = 4,
    this.hourNumberScale = 1.5,
    this.hourHandLength = 11,
    this.minuteHandLength = 15,
    this.hourHandWidth = 1,
    this.minuteHandWidth = 1,
    this.fontSize = 7,
  });
}

class ClockLayoutMedium extends ClockLayout {
  const ClockLayoutMedium({
    double? height,
    double? width,
  }) : super(
          height: height ?? 120,
          width: width ?? 96,
          borderWidth: 2,
          centerPointRadius: 8,
          hourNumberScale: 1.5,
          hourHandLength: 22,
          minuteHandLength: 30,
          hourHandWidth: 1.5,
          minuteHandWidth: 1.5,
          fontSize: 12,
        );
}

class ClockLayoutLarge extends ClockLayoutMedium {
  const ClockLayoutLarge()
      : super(
          height: 172,
          width: 138,
        );
}
