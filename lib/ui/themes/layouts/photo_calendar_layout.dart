import 'package:seagull/ui/all.dart';

// PhotoCalendar not implemented in MPGO
class PhotoCalendarLayout {
  final Size appBarSize;
  final EdgeInsets analogClockPadding, digitalClockPadding;
  final double clockDistance,
      clockRowHeight,
      analogClockSize,
      digitalClockFontSize;
  final FontWeight digitalClockFontWeight;
  final Offset backButtonPosition;

  const PhotoCalendarLayout({
    this.appBarSize = const Size.square(0),
    this.analogClockPadding = EdgeInsets.zero,
    this.digitalClockPadding = EdgeInsets.zero,
    this.clockDistance = 0,
    this.clockRowHeight = 0,
    this.analogClockSize = 0,
    this.backButtonPosition = Offset.zero,
    this.digitalClockFontSize = 0,
    this.digitalClockFontWeight = FontWeight.normal,
  });
}

class MediumPhotoCalendarLayout extends PhotoCalendarLayout {
  const MediumPhotoCalendarLayout({
    Size? appBarSize,
    EdgeInsets? analogClockPadding,
    EdgeInsets? digitalClockPadding,
    double? clockDistance,
    double? clockRowHeight,
    double? digitalClockFontSize,
    double? analogClockSize,
    FontWeight? digitalClockFontWeight,
    Offset? backButtonPosition,
  }) : super(
          appBarSize: appBarSize ?? const Size.fromHeight(216),
          analogClockPadding:
              analogClockPadding ?? const EdgeInsets.only(top: 3),
          digitalClockPadding:
              digitalClockPadding ?? const EdgeInsets.only(top: 76),
          clockDistance: clockDistance ?? 27,
          clockRowHeight: clockRowHeight ?? 248,
          digitalClockFontSize: digitalClockFontSize ?? 64,
          analogClockSize: analogClockSize ?? 200,
          digitalClockFontWeight: digitalClockFontWeight ?? FontWeight.w400,
          backButtonPosition: backButtonPosition ?? const Offset(24, 32),
        );
}

class LargePhotoCalendarLayout extends MediumPhotoCalendarLayout {
  const LargePhotoCalendarLayout()
      : super(
          clockRowHeight: 384,
          analogClockSize: 320,
          analogClockPadding: const EdgeInsets.only(top: 17),
          digitalClockPadding: const EdgeInsets.only(top: 129),
          clockDistance: 64,
          backButtonPosition: const Offset(24, 24),
          digitalClockFontSize: 112,
          digitalClockFontWeight: FontWeight.w300,
        );
}
