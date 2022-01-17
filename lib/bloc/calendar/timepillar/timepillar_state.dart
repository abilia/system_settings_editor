part of 'timepillar_cubit.dart';

// ActivityTimepillarCard
final double _imageHeightMin = layout.timePillarLayout.imageHeightMin.s;
final double _cardPadding = layout.timePillarLayout.cardPadding.s;
final double _width = layout.timePillarLayout.width.s;
final double _padding = layout.timePillarLayout.padding.s;
final double _minHeight = layout.timePillarLayout.minHeight.s;

// Dots
final double _dotSize = layout.timePillarLayout.dotSize.s;
final double _hourPadding = layout.timePillarLayout.hourPadding.s;
final double _dotPadding = layout.timePillarLayout.dotPadding.s;
final double _dotDistance = layout.timePillarLayout.dotDistance.s;

// Timepillar
final double _timePillarPadding = layout.timePillarLayout.timePillarPadding.s;
final double defaultTimePillarWidth =
    layout.timePillarLayout.defaultTimePillarWidth.s;

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;
  final double zoom;

  const TimepillarState(this.timepillarInterval, this.zoom);

  // ActivityTimepillarCard
  double get minImageHeight => _imageHeightMin * zoom;
  double get cardPadding => _cardPadding * zoom;
  double get width => _width * zoom;
  double get padding => _padding * zoom;
  double get minHeight => _minHeight * zoom;
  double get totalWidth => (_dotSize + _width + _padding) * zoom;
  double get textWidth => width - cardPadding * 2;

  // Dots
  double get dotSize => _dotSize * zoom;
  double get dotDistance => (_dotSize + _dotPadding) * zoom;
  double get hourHeight => _dotDistance * dotsPerHour * zoom;
  double get hourPadding => _hourPadding * zoom;
  double get dotPadding => _dotPadding * zoom;

  // Timepillar
  double get timePillarPadding => _timePillarPadding * zoom;
  double get timePillarWidth => defaultTimePillarWidth * zoom;
  double get timePillarTotalWidth =>
      (defaultTimePillarWidth + _timePillarPadding * 2) * zoom;
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
