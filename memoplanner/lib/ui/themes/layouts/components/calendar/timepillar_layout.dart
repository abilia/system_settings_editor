import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/all.dart';

class TimepillarLayout {
  final double fontSize,
      fontHeight,
      width,
      padding,
      hourIntervalPadding,
      hourTextPadding,
      hourLineWidth,
      topMargin,
      bottomMargin,
      timeLineHeight,
      flarpRadius;

  final TimepillarDotLayout dot;
  final TimepillarCardLayout card;
  final TwoTimepillarLayout twoTimePillar;

  const TimepillarLayout({
    this.fontSize = 20,
    this.fontHeight = 23 / 20.0,
    this.width = 42,
    this.padding = 10,
    this.hourIntervalPadding = 1,
    this.hourTextPadding = 3,
    this.hourLineWidth = 1,
    this.topMargin = 96,
    this.bottomMargin = 64,
    this.timeLineHeight = 2,
    this.flarpRadius = 8,
    this.dot = const TimepillarDotLayout(),
    this.card = const TimepillarCardLayout(),
    this.twoTimePillar = const TwoTimepillarLayout(),
  });

  TextStyle textStyle(bool isNight, double zoom) => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: fontSize * zoom,
          height: fontHeight * zoom,
          color: isNight ? AbiliaColors.white : AbiliaColors.black,
          fontWeight: FontWeight.w500,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class TimepillarLayoutMedium extends TimepillarLayout {
  const TimepillarLayoutMedium({
    double? fontSize,
    double? fontHeight,
    double? width,
    double? hourIntervalPadding,
    double? hourTextPadding,
    double? hourLineWidth,
    TimepillarDotLayout? dot,
    TimepillarCardLayout? card,
    TwoTimepillarLayout? twoTimePillar,
  }) : super(
          fontSize: fontSize ?? 40,
          fontHeight: fontHeight ?? 48 / 40.0,
          width: width ?? 80,
          padding: 8,
          hourIntervalPadding: hourIntervalPadding ?? 1.5,
          hourTextPadding: hourTextPadding ?? 4.5,
          hourLineWidth: hourLineWidth ?? 1,
          flarpRadius: 12,
          dot: dot ??
              const TimepillarDotLayout(
                size: 16,
                padding: 4,
              ),
          card: card ??
              const TimepillarCardLayout(
                width: 120,
                activityMinHeight: 140,
                imageMinHeight: 96,
                padding: EdgeInsets.all(8),
                distance: 8,
                fontSize: 20,
                fontHeight: 24 / 20.0,
              ),
          twoTimePillar: twoTimePillar ??
              const TwoTimepillarLayout(
                verticalMargin: 36,
                nightMargin: 6,
                radius: 18,
              ),
        );
}

class TimepillarLayoutLarge extends TimepillarLayoutMedium {
  const TimepillarLayoutLarge()
      : super(
          fontSize: 48,
          fontHeight: 1,
          width: 101,
          hourIntervalPadding: 2,
          hourLineWidth: 2,
          hourTextPadding: 4,
          dot: const TimepillarDotLayout(
            size: 18,
            padding: 6,
          ),
          card: const TimepillarCardLayout(
            width: 164,
            activityMinHeight: 192,
            imageMinHeight: 128,
            padding: EdgeInsets.all(8),
            distance: 8,
            fontSize: 28,
            fontHeight: 40 / 28.0,
          ),
        );
}

class TimepillarDotLayout {
  final double size, padding, distance;

  const TimepillarDotLayout({
    this.size = 10,
    this.padding = 3,
  }) : distance = size + padding;
}

class TimepillarCardLayout {
  final TimerCardLayout timer;
  final double distance, width, activityMinHeight, imageMinHeight;
  final double fontSize, fontHeight;
  final EdgeInsets padding;

  const TimepillarCardLayout({
    this.timer = const TimerCardLayout(),
    this.width = 72,
    this.activityMinHeight = 84,
    this.padding = const EdgeInsets.all(4),
    this.distance = 12,
    this.imageMinHeight = 56,
    this.fontSize = 12,
    this.fontHeight = 16 / 12.0,
  });

  TextStyle textStyle(double zoom) => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: fontSize * zoom,
          height: fontHeight,
          color: AbiliaColors.black,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class TwoTimepillarLayout {
  final double verticalMargin, nightMargin, radius;

  const TwoTimepillarLayout({
    this.verticalMargin = 24,
    this.radius = 9,
    this.nightMargin = 4,
  });
}
