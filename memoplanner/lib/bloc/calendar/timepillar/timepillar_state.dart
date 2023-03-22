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
  late final double cardImageSize = _layout.card.imageSize * zoom;
  late final double smallCardImageSize = _layout.card.smallImageSize * zoom;
  late final EdgeInsets imagePadding = _layout.card.imagePadding * zoom;
  late final EdgeInsets smallImagePadding =
      _layout.card.smallImagePadding * zoom;
  late final EdgeInsets textPadding = _layout.card.textPadding * zoom;
  late final double _cardWidth =
      _layout.card.imageSize + _layout.card.imagePadding.horizontal;
  late final double cardWidth = _cardWidth * zoom;
  late final double cardDistance = _layout.card.distance * zoom;
  late final double cardTotalWidth =
      (_layout.dot.size + _cardWidth + _layout.card.distance) * zoom;
  late final double cardTextWidth = cardWidth - textPadding.horizontal;

  BorderRadius get borderRadius => _layout.card.borderRadius;

  // ActivityTimepillarCard
  late final double activityCardMinHeight =
      _layout.card.activityMinHeight * zoom;

  // TimerTimepillarCard
  late final Size timerWheelSize = _layout.card.timer.largeWheelSize * zoom;
  late final EdgeInsets timerWheelPadding = _layout.card.timerPadding * zoom;

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

  static const maxTwoTimepillarRatio = 50;
  static const minTwoTimepillarRatio = 37;

  int twoTimpillarRatio(double nightPillarHeight) =>
      100 -
      (nightPillarHeight / (nightPillarHeight + timePillarHeight) * 100)
          .clamp(minTwoTimepillarRatio, maxTwoTimepillarRatio)
          .toInt();

  double getContentHeight({
    required EventOccasion occasion,
    required double textScaleFactor,
    required TextStyle textStyle,
    required BoxDecoration decoration,
  }) {
    final title = _getTitle(occasion);
    final hasContent =
        occasion is ActivityOccasion && occasion.hasTimepillarContent;
    final contentHeight = _getContentHeight(
      hasImage: occasion.hasImage,
      hasContent: hasContent,
      textStyle: textStyle,
      textScaleFactor: textScaleFactor,
      title: title,
    );
    if (occasion is TimerOccasion) {
      return contentHeight +
          timerWheelPadding.vertical / 2 +
          timerWheelSize.height;
    }
    return contentHeight;
  }

  String _getTitle(EventOccasion event) {
    if (event is TimerOccasion) {
      if (event.timer.hasImage) return '';
      if (!event.timer.hasTitle) return event.timer.duration.toHMSorMS();
    }
    return event.title;
  }

  double _getContentHeight({
    required bool hasImage,
    required TextStyle textStyle,
    required double textScaleFactor,
    required String title,
    required bool hasContent,
  }) {
    final hasTitle = title.isNotEmpty;
    final textHeight = hasTitle
        ? title
            .textPainter(
              textStyle,
              cardTextWidth,
              TimepillarCard.defaultTitleLines,
              scaleFactor: textScaleFactor,
            )
            .height
        : 0.0;
    final imageHeight = hasImage
        ? cardImageSize
        : hasContent
            ? smallCardImageSize
            : 0;
    final verticalImagePadding = hasImage
        ? imagePadding.vertical
        : hasContent
            ? smallImagePadding.vertical
            : 0;
    final verticalPadding = hasTitle && hasContent
        ? textPadding.vertical / 2 + verticalImagePadding
        : hasImage
            ? verticalImagePadding
            : textPadding.vertical;
    return textHeight + imageHeight + verticalPadding;
  }

  @override
  List<Object> get props => [interval, zoom];
}
