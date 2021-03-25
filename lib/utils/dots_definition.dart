import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/scale_util.dart';

const int dotsPerHour = 4,
    minutesPerDot = 60 ~/ dotsPerHour,
    minutePerSubDot = minutesPerDot ~/ 5,
    roundingMinute = minutesPerDot ~/ 2;
final double dotSize = 10.0.s,
    bigDotSize = 28.0.s,
    miniDotSize = 4.0.s,
    hourPadding = 1.0.s,
    dotPadding = hourPadding * 3,
    bigDotPadding = 6.0.s;

double timeToMidDotPixelDistance(DateTime now, TimepillarState ts) =>
    timeToPixels(now.hour, now.minute, ts.dotDistance) + ts.dotSize / 2;
double timeToPixels(int hours, int minutes, double dotDistance) =>
    (hours * dotsPerHour + minutes ~/ minutesPerDot) * dotDistance;
double hoursToPixels(int hours, double dotDistance) =>
    timeToPixels(hours, 0, dotDistance);
