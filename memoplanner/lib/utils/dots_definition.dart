import 'package:memoplanner/ui/all.dart';

const int dotsPerHour = 4,
    minutesPerDot = 60 ~/ dotsPerHour,
    minutePerSubDot = minutesPerDot ~/ 5,
    roundingMinute = minutesPerDot ~/ 2;
const minutesPerDotDuration = Duration(minutes: minutesPerDot);
final bigDotSize = layout.dot.bigDotSize,
    miniDotSize = layout.dot.miniDotSize,
    bigDotPadding = layout.dot.bigDotPadding;

double timeToMidDotPixelDistance({
  required DateTime now,
  required double dotDistance,
  required double dotSize,
}) =>
    timeToPixels(now.hour, now.minute, dotDistance) + dotSize / 2;
double timeToPixels(int hours, int minutes, double dotDistance) =>
    (hours * dotsPerHour + minutes ~/ minutesPerDot) * dotDistance;
double durationToPixels(Duration duration, double dotDistance) =>
    timeToPixels(0, duration.inMinutes, dotDistance);
double hoursToPixels(int hours, double dotDistance) =>
    timeToPixels(hours, 0, dotDistance);

Duration yPosToDuration(double dy, double dotDistance) {
  final hours = dy / (dotDistance * dotsPerHour);
  final hoursInt = hours.truncate();
  final minutes = ((hours - hoursInt) * 60).round();
  return Duration(hours: hoursInt, minutes: minutes);
}
