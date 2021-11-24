part of 'timepillar_bloc.dart';

// ActivityTimepillarCard
final double _imageHeightMin = 56.s;
final double _cardPadding = 4.s;
final double _width = 72.s;
final double _padding = 12.s;
final double _minHeight = 84.s;

// Dots
final double _dotSize = 10.s;
final double _hourPadding = 1.s;
final double _dotPadding = _hourPadding * 3;
final double _dotDistance = _dotSize + _dotPadding;

// Timepillar
final double _timePillarPadding = 4.s;
final double defaultTimePillarWidth = 42.s;

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
