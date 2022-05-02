part of 'timepillar_cubit.dart';

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;
  final List<Event> events;
  final DayCalendarType calendarType;
  final Occasion occasion;
  final bool forceFullDay;

  const TimepillarState(
    this.timepillarInterval,
    this.events,
    this.calendarType,
    this.occasion,
    this.forceFullDay,
  );

  @override
  List<Object> get props => [timepillarInterval, events, calendarType];

  bool get isToday => occasion == Occasion.current;
}

class TimepillarMeasures extends Equatable {
  final double zoom;
  final TimepillarInterval timepillarInterval;
  final TimepillarLayout _layout = layout.timePillar;

  TimepillarMeasures(this.timepillarInterval, this.zoom);

  // TimepillarCard
  late final double cardMinImageHeight = _layout.card.imageMinHeight * zoom;
  late final EdgeInsets cardPadding = _layout.card.padding * zoom;
  late final double cardWidth = _layout.card.width * zoom;
  late final double cardDistance = _layout.card.distance * zoom;
  late final double cardTotalWidth =
      (_layout.dot.size + _layout.card.width + _layout.card.distance) * zoom;
  late final double cardTextWidth = cardWidth - cardPadding.vertical;

  // ActivityTimepillarCard
  late final double activityCardMinHeight =
      _layout.card.activityMinHeight * zoom;

  // TimerTimepillarCard
  late final Size timerWheelSize = _layout.card.timer.wheelSize * zoom;
  late final double timerMinHeight = _layout.card.timer.minHeigth * zoom;
  late final EdgeInsets timerWheelPadding =
      _layout.card.timer.wheelPadding * zoom;

  // Dots
  late final double dotSize = _layout.dot.size * zoom;
  late final double dotDistance = _layout.dot.distance * zoom;
  late final double hourHeight = _layout.dot.distance * dotsPerHour * zoom;
  late final double hourPadding = _layout.hourPadding * zoom;
  late final double dotPadding = _layout.dot.padding * zoom;

  // Timepillar
  late final double timePillarPadding = _layout.padding * zoom;

  late final double timePillarWidth = _layout.width * zoom;
  late final double timePillarTotalWidth =
      (_layout.width + _layout.padding * 2) * zoom;
  late final double timePillarHeight = (timepillarInterval.lengthInHours +
          // include one extra hour for the last digit after the timepillar
          // (alternatively, adding the font height of the text would also work)
          1) *
      hourHeight;
  late final double topPadding = 2 * hourPadding;
  late final double hourLineWidth = _layout.hourLineWidth * zoom;
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
