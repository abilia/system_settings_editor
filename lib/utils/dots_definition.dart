const int dotsPerHour = 4,
    minutesPerDot = 60 ~/ dotsPerHour,
    minutePerSubDot = minutesPerDot ~/ 5,
    roundingMinute = minutesPerDot ~/ 2;
const double dotSize = 10.0,
    bigDotSize = 28.0,
    miniDotSize = 4.0,
    hourPadding = 1.0,
    dotPadding = hourPadding * 3,
    bigDotPadding = 6.0,
    dotDistance = dotSize + dotPadding,
    hourHeigt = dotDistance * dotsPerHour;

double timeToMidDotPixelDistance(DateTime now) =>
    timeToPixels(now.hour, now.minute) + dotSize / 2;
double timeToPixels(int hours, int minutes) =>
    (hours * dotsPerHour + minutes ~/ minutesPerDot) * dotDistance;
double hoursToPixels(int hours) => timeToPixels(hours, 0);
