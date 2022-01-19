part of 'timepillar_cubit.dart';

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;
  final double zoom;

  const TimepillarState(this.timepillarInterval, this.zoom);

  // ActivityTimepillarCard
  double get minImageHeight => layout.timePillar.imageHeightMin * zoom;
  double get cardPadding => layout.timePillar.cardPadding * zoom;
  double get width => layout.timePillar.width * zoom;
  double get padding => layout.timePillar.padding * zoom;
  double get minHeight => layout.timePillar.minHeight * zoom;
  double get totalWidth =>
      (layout.timePillar.dotSize +
          layout.timePillar.width +
          layout.timePillar.padding) *
      zoom;
  double get textWidth => width - cardPadding * 2;

  // Dots
  double get dotSize => layout.timePillar.dotSize * zoom;
  double get dotDistance =>
      (layout.timePillar.dotSize + layout.timePillar.dotPadding) * zoom;
  double get hourHeight => layout.timePillar.dotDistance * dotsPerHour * zoom;
  double get hourPadding => layout.timePillar.hourPadding * zoom;
  double get dotPadding => layout.timePillar.dotPadding * zoom;

  // Timepillar
  double get timePillarPadding => layout.timePillar.timePillarPadding * zoom;
  double get timePillarWidth => layout.timePillar.defaultTimePillarWidth * zoom;
  double get timePillarTotalWidth =>
      (layout.timePillar.defaultTimePillarWidth +
          layout.timePillar.timePillarPadding * 2) *
      zoom;
  double get topPadding => 2 * hourPadding;
  bool get intervalSpansMidnight =>
      timepillarInterval.endTime.isDayAfter(timepillarInterval.startTime);

  double topOffset(DateTime hour) {
    if (intervalSpansMidnight &&
        hour.hour < timepillarInterval.startTime.hour) {
      return hoursToPixels(
        timepillarInterval.startTime.hour - Duration.hoursPerDay,
        dotDistance,
      );
    }
    return hoursToPixels(timepillarInterval.startTime.hour, dotDistance);
  }

  @override
  List<Object> get props => [timepillarInterval, zoom];
}
