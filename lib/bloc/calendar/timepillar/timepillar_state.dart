part of 'timepillar_cubit.dart';

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;
  final double zoom;
  final TimepillarLayout timePillarLayout = layout.timePillar;

  TimepillarState(this.timepillarInterval, this.zoom);

  // ActivityTimepillarCard
  double get minImageHeight => timePillarLayout.card.imageHeightMin * zoom;
  double get cardPadding => timePillarLayout.card.padding * zoom;
  double get width => timePillarLayout.card.width * zoom;
  double get padding => timePillarLayout.calendar.padding * zoom;
  double get minHeight => timePillarLayout.card.minHeight * zoom;
  double get totalWidth =>
      (timePillarLayout.dot.size +
          timePillarLayout.card.width +
          timePillarLayout.calendar.padding) *
      zoom;
  double get textWidth => width - cardPadding * 2;

  // Dots
  double get dotSize => timePillarLayout.dot.size * zoom;
  double get dotDistance =>
      (timePillarLayout.dot.size + timePillarLayout.dot.padding) * zoom;
  double get hourHeight => timePillarLayout.dot.distance * dotsPerHour * zoom;
  double get hourPadding => timePillarLayout.calendar.hourPadding * zoom;
  double get dotPadding => timePillarLayout.dot.padding * zoom;

  // Timepillar
  double get timePillarPadding =>
      timePillarLayout.calendar.timePillarPadding * zoom;
  double get timePillarWidth =>
      timePillarLayout.calendar.defaultTimePillarWidth * zoom;
  double get timePillarTotalWidth =>
      (timePillarLayout.calendar.defaultTimePillarWidth +
          timePillarLayout.calendar.timePillarPadding * 2) *
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
