part of 'timepillar_cubit.dart';

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;
  final double zoom;
  final TimepillarLayout timePillarLayout = layout.timePillar;

  TimepillarState(this.timepillarInterval, this.zoom);

  // ActivityTimepillarCard
  late final double minImageHeight =
      timePillarLayout.card.imageHeightMin * zoom;
  late final double cardPadding = timePillarLayout.card.margin * zoom;
  late final double width = timePillarLayout.card.width * zoom;
  late final double padding = timePillarLayout.card.padding * zoom;
  late final double minHeight = timePillarLayout.card.minHeight * zoom;
  late final double totalWidth = (timePillarLayout.dot.size +
          timePillarLayout.card.width +
          timePillarLayout.card.padding) *
      zoom;
  late final double textWidth = width - cardPadding * 2;

  // Dots
  late final double dotSize = timePillarLayout.dot.size * zoom;
  late final double dotDistance = timePillarLayout.dot.distance * zoom;
  late final double hourHeight =
      timePillarLayout.dot.distance * dotsPerHour * zoom;
  late final double hourPadding = timePillarLayout.hourPadding * zoom;
  late final double dotPadding = timePillarLayout.dot.padding * zoom;

  // Timepillar
  late final double timePillarPadding = timePillarLayout.padding * zoom;
  late final double timePillarWidth = timePillarLayout.width * zoom;
  late final double timePillarTotalWidth =
      (timePillarLayout.width + timePillarLayout.padding * 2) * zoom;
  late final double timePillarHeight = (timepillarInterval.lengthInHours +
          1) * // include one extra hour for the last digit after the timepillar (could only be the font size of the text)
      hourHeight;
  late final double topPadding = 2 * hourPadding;
  late final double hourLineWidth = timePillarLayout.hourLineWidth * zoom;
  late final bool intervalSpansMidnight =
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
