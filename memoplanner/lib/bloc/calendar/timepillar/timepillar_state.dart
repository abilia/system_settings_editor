part of 'timepillar_cubit.dart';

class TimepillarState extends Equatable {
  final TimepillarInterval interval;
  final List<Event> events;
  final DayCalendarType calendarType;
  final Occasion occasion;
  final bool showNightCalendar;
  final DateTime day;

  const TimepillarState({
    required this.interval,
    required this.events,
    required this.calendarType,
    required this.occasion,
    required this.showNightCalendar,
    required this.day,
  });

  @override
  List<Object> get props => [interval, events, calendarType, occasion, day];

  bool get isToday => occasion.isCurrent;

  List<Event> eventsForInterval(TimepillarInterval interval) => events
      .where(
        (a) =>
            a.start.inRangeWithInclusiveStart(
              startDate: interval.start,
              endDate: interval.end,
            ) ||
            a.start.isBefore(interval.start) && a.end.isAfter(interval.start),
      )
      .toList();
}

class TimepillarMeasures extends Equatable {
  final double zoom;
  final TimepillarInterval interval;
  final TimepillarLayout _layout = layout.timepillar;

  TimepillarMeasures(this.interval, this.zoom);

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
  late final Size timerWheelSize = _layout.card.timer.largeWheelSize * zoom;
  late final double timerMinHeight = _layout.card.timer.minHeight * zoom;
  late final EdgeInsets timerWheelPadding =
      _layout.card.timer.wheelPadding * zoom;

  // Dots
  late final double dotSize = _layout.dot.size * zoom;
  late final double dotDistance = _layout.dot.distance * zoom;
  late final double hourHeight = _layout.dot.distance * dotsPerHour * zoom;
  late final double dotPadding = _layout.dot.padding * zoom;

  // Timepillar
  late final double timePillarPadding = _layout.padding * zoom;
  late final double hourIntervalPadding = _layout.hourIntervalPadding * zoom;
  late final EdgeInsets hourTextPadding = EdgeInsets.only(
      top: _layout.hourTextPadding * zoom - hourIntervalPadding,
      bottom: _layout.hourTextPadding * zoom);

  late final double timePillarWidth = _layout.width * zoom;
  late final double timePillarTotalWidth =
      (_layout.width + _layout.padding * 2) * zoom;
  late final double timePillarHeight = (interval.lengthInHours +
          // include one extra hour for the last digit after the timepillar
          // (alternatively, adding the font height of the text would also work)
          1) *
      hourHeight;
  late final double topPadding = 2 * hourIntervalPadding;
  late final double hourLineWidth = _layout.hourLineWidth * zoom;

  double topOffset(DateTime hour) {
    if (interval.spansMidnight && hour.hour < interval.start.hour) {
      return hoursToPixels(
        interval.start.hour - Duration.hoursPerDay,
        dotDistance,
      );
    }
    return hoursToPixels(interval.start.hour, dotDistance);
  }

  @override
  List<Object> get props => [interval, zoom];
}

class TimepillarRatios {
  static const maxRatio = 50;
  static const minRatio = 37;

  final int dayTimepillarRatio;
  final int nightTimepillarRatio;

  TimepillarRatios._({
    required this.dayTimepillarRatio,
    required this.nightTimepillarRatio,
  });

  factory TimepillarRatios({
    required double dayPillarHeight,
    required double nightPillarHeight,
  }) {
    final heights = nightPillarHeight + dayPillarHeight;
    var nightPillarRatio = (nightPillarHeight / heights * 100).toInt();

    if (nightPillarRatio < minRatio) {
      nightPillarRatio = minRatio;
    } else if (nightPillarRatio > maxRatio) {
      nightPillarRatio = maxRatio;
    }

    return TimepillarRatios._(
      nightTimepillarRatio: nightPillarRatio,
      dayTimepillarRatio: 100 - nightPillarRatio,
    );
  }
}
