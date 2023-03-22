import 'package:google_fonts/google_fonts.dart';
import 'package:memoplanner/ui/all.dart';

class TimepillarLayout {
  final double fontSize,
      fontHeight,
      width,
      padding,
      hourIntervalPadding,
      hourTextPadding,
      hourLineWidth,
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
                activityMinHeight: 140,
                imageSize: 104,
                smallImageSize: 24,
                imagePadding: EdgeInsets.all(8),
                smallImagePadding: EdgeInsets.all(8),
                textPadding: EdgeInsets.all(12),
                timerPadding: EdgeInsets.all(12),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                imageCornerRadius: BorderRadius.all(Radius.circular(16)),
                crossPadding: EdgeInsets.all(16),
                checkPadding: EdgeInsets.all(20),
                smallCrossPadding: EdgeInsets.all(4),
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
            activityMinHeight: 192,
            imageSize: 148,
            smallImageSize: 32,
            imagePadding: EdgeInsets.all(8),
            smallImagePadding: EdgeInsets.all(8),
            textPadding: EdgeInsets.all(12),
            timerPadding: EdgeInsets.all(16),
            borderRadius: BorderRadius.all(Radius.circular(24)),
            imageCornerRadius: BorderRadius.all(Radius.circular(20)),
            crossPadding: EdgeInsets.all(16),
            checkPadding: EdgeInsets.all(20),
            smallCrossPadding: EdgeInsets.all(4),
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
  final double distance, activityMinHeight, imageSize, smallImageSize;
  final double fontSize, fontHeight;
  final BorderRadius borderRadius;
  final BorderRadius imageCornerRadius;
  final EdgeInsets imagePadding, smallImagePadding;
  final EdgeInsets textPadding;
  final EdgeInsets timerPadding;
  final EdgeInsets crossPadding, checkPadding, smallCrossPadding;

  const TimepillarCardLayout({
    this.timer = const TimerCardLayout(),
    this.activityMinHeight = 84,
    this.imagePadding = const EdgeInsets.all(4),
    this.smallImagePadding = const EdgeInsets.all(5),
    this.textPadding = const EdgeInsets.all(6),
    this.timerPadding = const EdgeInsets.all(8),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.imageCornerRadius = const BorderRadius.all(Radius.circular(10)),
    this.crossPadding = const EdgeInsets.all(8),
    this.checkPadding = const EdgeInsets.all(10),
    this.smallCrossPadding = const EdgeInsets.all(2),
    this.distance = 12,
    this.imageSize = 64,
    this.smallImageSize = 14,
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
