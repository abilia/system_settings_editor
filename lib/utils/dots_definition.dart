import 'package:seagull/utils/scale_util.dart';

const int dotsPerHour = 4,
    minutesPerDot = 60 ~/ dotsPerHour,
    minutePerSubDot = minutesPerDot ~/ 5,
    roundingMinute = minutesPerDot ~/ 2;
final bigDotSize = 28.0.s,
    miniDotSize = 4.0.s,
    hourPadding = 1.0.s,
    bigDotPadding = 6.0.s;

double timeToMidDotPixelDistance({
  DateTime now,
  double dotDistance,
  double dotSize,
}) =>
    timeToPixels(now.hour, now.minute, dotDistance) + dotSize / 2;
double timeToPixels(int hours, int minutes, double dotDistance) =>
    (hours * dotsPerHour + minutes ~/ minutesPerDot) * dotDistance;
double hoursToPixels(int hours, double dotDistance) =>
    timeToPixels(hours, 0, dotDistance);
