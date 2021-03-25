part of 'timepillar_bloc.dart';

// ActivityTimepillarCard
final double _imageSize = 56.0.s;
final double _imagePadding = 16.0.s;
final double _crossWidth = 48.0.s;
final double _crossVerticalPadding = 36.0.s;
final double _width = 72.0.s;
final double _padding = 12.0.s;
final double _minHeight = 84.0.s;

// Dots
final double _dotSize = 10.0.s;
final double _dotPadding = hourPadding * 3;
final double _dotDistance = _dotSize + _dotPadding;

// Timepillar
final double _timePillarPadding = 4.0.s;
final double _timePillarWidth = 42.0.s;

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;
  final double zoom;

  const TimepillarState(this.timepillarInterval, this.zoom);

  // ActivityTimepillarCard
  double get imageSize => _imageSize * zoom;
  double get imageHeight => (_imageSize + _imagePadding) * zoom;
  double get crossWidth => _crossWidth * zoom;
  double get crossVerticalPadding => _crossVerticalPadding * zoom;
  double get width => _width * zoom;
  double get padding => _padding * zoom;
  double get minHeight => _minHeight * zoom;
  double get totalWidth => (_dotSize + _width + _padding) * zoom;

  // Dots
  double get dotSize => _dotSize * zoom;
  double get dotDistance => (_dotSize + _dotPadding) * zoom;
  double get hourHeight => _dotDistance * dotsPerHour * zoom;
  double get dotPadding => _dotPadding * zoom;

  // Timepillar
  double get timePillarPadding => _timePillarPadding * zoom;
  double get timePillarWidth => _timePillarWidth * zoom;
  double get timePillarTotalWidth =>
      (_timePillarWidth + _timePillarPadding * 2) * zoom;

  @override
  List<Object> get props => [timepillarInterval];
}
