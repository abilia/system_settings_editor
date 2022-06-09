import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

// PhotoCalendar not implemented in MPGO
class PhotoCalendarLayoutMedium {
  final Size appBarSize;
  final EdgeInsets analogClockPadding, digitalClockPadding;
  final double clockDistance,
      clockRowHeight,
      analogClockSize,
      digitalClockFontSize,
      digitalClockFontSizeLarge;
  final FontWeight digitalClockFontWeight;
  final Offset backButtonPosition;

  TextStyle textStyle(ClockType clockType) => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: clockType == ClockType.digital
              ? digitalClockFontSizeLarge
              : digitalClockFontSize,
          height: 1,
          fontWeight: digitalClockFontWeight,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );

  const PhotoCalendarLayoutMedium({
    this.appBarSize = const Size.fromHeight(216),
    this.analogClockPadding = const EdgeInsets.only(top: 3),
    this.digitalClockPadding = const EdgeInsets.only(top: 76),
    this.clockDistance = 27,
    this.clockRowHeight = 248,
    this.analogClockSize = 200,
    this.backButtonPosition = const Offset(24, 32),
    this.digitalClockFontSize = 64,
    this.digitalClockFontSizeLarge = 72,
    this.digitalClockFontWeight = FontWeight.w400,
  });
}

class PhotoCalendarLayoutLarge extends PhotoCalendarLayoutMedium {
  const PhotoCalendarLayoutLarge()
      : super(
          clockRowHeight: 384,
          analogClockSize: 320,
          analogClockPadding: const EdgeInsets.only(top: 17),
          digitalClockPadding: const EdgeInsets.only(top: 129),
          clockDistance: 64,
          backButtonPosition: const Offset(24, 24),
          digitalClockFontSize: 112,
          digitalClockFontSizeLarge: 132,
          digitalClockFontWeight: FontWeight.w300,
        );
}
