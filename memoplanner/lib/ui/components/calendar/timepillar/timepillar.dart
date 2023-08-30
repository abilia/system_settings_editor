import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class SelectionRange {
  final Duration start;
  final Duration duration;
  Duration get end => start + duration;
  SelectionRange(this.start, {this.duration = Duration.zero});

  bool inRange(Duration t) =>
      t.inMilliseconds >= start.inMilliseconds &&
      t.inMilliseconds <= end.inMilliseconds;

  @override
  String toString() => 'SelectionRange {'
      'start: $start '
      'duration: $duration}';
}

class TimePillarWithAddActivity extends StatelessWidget {
  final TimepillarInterval interval;
  final Occasion dayOccasion;
  final bool use12h;
  final List<NightPart> nightParts;
  final DayParts dayParts;
  final bool columnOfDots;
  final double topMargin;
  final TimepillarMeasures measures;

  const TimePillarWithAddActivity({
    required this.interval,
    required this.dayOccasion,
    required this.use12h,
    required this.nightParts,
    required this.dayParts,
    required this.columnOfDots,
    required this.topMargin,
    required this.measures,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context) {
    final tapOnTp = context.select((FeatureToggleCubit c) => c
        .state.featureToggles
        .contains(FeatureToggle.tapTimepillarToAddActivity));
    if (tapOnTp) {
      return _ClickableTimePillar(
        interval: interval,
        dayOccasion: dayOccasion,
        use12h: use12h,
        nightParts: nightParts,
        dayParts: dayParts,
        columnOfDots: columnOfDots,
        topMargin: topMargin,
        measures: measures,
      );
    }
    return TimePillar(
      interval: interval,
      dayOccasion: dayOccasion,
      use12h: use12h,
      nightParts: nightParts,
      dayParts: dayParts,
      columnOfDots: columnOfDots,
      topMargin: topMargin,
      measures: measures,
    );
  }
}

class TimePillar extends StatelessWidget {
  final TimepillarInterval interval;
  final Occasion dayOccasion;
  final bool use12h;
  final List<NightPart> nightParts;
  final DayParts dayParts;
  final bool columnOfDots;
  final bool preview;
  final double topMargin;
  final TimepillarMeasures measures;
  final SelectionRange? selectionRange;

  const TimePillar({
    required this.interval,
    required this.dayOccasion,
    required this.use12h,
    required this.nightParts,
    required this.dayParts,
    required this.columnOfDots,
    required this.topMargin,
    required this.measures,
    this.selectionRange,
    this.preview = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatHour = onlyHourFormat(context, use12h: use12h);
    final selectionRange = this.selectionRange;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        measures.timePillarPadding,
        topMargin,
        measures.timePillarPadding,
        0,
      ),
      child: SizedBox(
        width: measures.timePillarWidth,
        child: Stack(
          children: [
            if (selectionRange != null)
              Positioned(
                top: durationToPixels(
                  selectionRange.start -
                      interval.start.toDurationFromMidNight(),
                  measures.dotDistance,
                ),
                width: measures.timePillarWidth,
                height: durationToPixels(
                  selectionRange.duration + minutesPerDotDuration,
                  measures.dotDistance,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AbiliaColors.green.withAlpha(0x19),
                    borderRadius: borderRadius,
                  ),
                ),
              ),
            Column(
              children: [
                ...List.generate(
                  interval.lengthInHours,
                  (index) {
                    final hourIndex = index + interval.start.hour;
                    final hour =
                        interval.start.onlyDays().copyWith(hour: hourIndex);
                    final isNight = hour.isNight(dayParts);
                    return Hour(
                      hour: formatHour(hour),
                      dots: TimePillarHourDots(
                        hour: hour,
                        isNight: isNight,
                        columnOfDots: columnOfDots,
                        selectionRange: selectionRange,
                      ),
                      isNight: isNight,
                      measures: measures,
                    );
                  },
                ),
                if (!preview)
                  Hour(
                    hour: formatHour(interval.end),
                    dots: SizedBox(
                      width: measures.dotSize,
                      height: measures.dotSize,
                    ),
                    isNight: interval.end.subtract(1.hours()).isNight(dayParts),
                    measures: measures,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClickableTimePillar extends StatefulWidget {
  final TimepillarInterval interval;
  final Occasion dayOccasion;
  final bool use12h;
  final List<NightPart> nightParts;
  final DayParts dayParts;
  final bool columnOfDots;
  final double topMargin;
  final TimepillarMeasures measures;

  const _ClickableTimePillar({
    required this.interval,
    required this.dayOccasion,
    required this.use12h,
    required this.nightParts,
    required this.dayParts,
    required this.columnOfDots,
    required this.topMargin,
    required this.measures,
  });

  @override
  State<_ClickableTimePillar> createState() => _TimePillarState();
}

class _TimePillarState extends State<_ClickableTimePillar>
    with ActivityNavigation {
  SelectionRange? selectionRange;
  Duration? durationOrigin;

  bool isDotTap(double dx) =>
      dx > widget.measures.timePillarWidth - 2 * widget.measures.dotSize;

  Duration _start(Offset localPosition) {
    final dy = localPosition.dy - widget.topMargin;
    final duration = yPosToDuration(dy, widget.measures.dotDistance);
    final durationRounded = isDotTap(localPosition.dx)
        ? duration.roundDownToClosestDot()
        : duration.roundUpToClosestHour();
    return durationRounded + widget.interval.start.toDurationFromMidNight();
  }

  SelectionRange? _end(Offset localPosition) {
    final sr = selectionRange;
    if (sr == null) return null;
    final p = yPosToDuration(
          localPosition.dy - widget.topMargin,
          widget.measures.dotDistance,
        ).roundDownToClosestDot() +
        widget.interval.start.toDurationFromMidNight();
    final tapOrigin = durationOrigin;
    if (tapOrigin != null && p > tapOrigin) {
      return SelectionRange(sr.start, duration: p - sr.start);
    }
    // Has swiped up
    durationOrigin = p;
    return SelectionRange(p);
  }

  Future<void> onTapUp(TapUpDetails details) async {
    final sr = selectionRange;
    final s = _start(details.localPosition);
    if (sr == null) return setState(() => selectionRange = SelectionRange(s));
    setState(() => selectionRange = null);
    if (sr.inRange(s)) {
      return navigateToActivityWizardWithContext(
        context,
        copiedAuthProviders(context),
        basicActivity: BasicActivityDataItem.createNew(
          startTime: sr.start,
          duration: sr.duration == Duration.zero
              ? Duration.zero
              : sr.duration + minutesPerDotDuration,
        ),
        addActivityMode: AddActivityMode.editView,
      );
    }
  }

  void onLongPressStart(LongPressStartDetails details) {
    final start = _start(details.localPosition);
    durationOrigin = start;
    setState(
      () => selectionRange = SelectionRange(start),
    );
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) =>
      setState(() => selectionRange = _end(details.localPosition));

  void onLongPressUp() => durationOrigin = null;

  @override
  Widget build(BuildContext context) {
    debugPrint('$selectionRange');
    return GestureDetector(
      onTapUp: onTapUp,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      child: TimePillar(
        interval: widget.interval,
        dayOccasion: widget.dayOccasion,
        use12h: widget.use12h,
        nightParts: widget.nightParts,
        dayParts: widget.dayParts,
        columnOfDots: widget.columnOfDots,
        topMargin: widget.topMargin,
        measures: widget.measures,
        selectionRange: selectionRange,
      ),
    );
  }
}

class Hour extends StatelessWidget {
  const Hour({
    required this.hour,
    required this.dots,
    required this.isNight,
    required this.measures,
    Key? key,
  }) : super(key: key);

  final String hour;
  final Widget dots;
  final bool isNight;
  final TimepillarMeasures measures;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: layout.timepillar.textStyle(isNight, measures.zoom),
      softWrap: false,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.end,
      child: Container(
        height: measures.hourHeight,
        padding: EdgeInsets.symmetric(vertical: measures.hourIntervalPadding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AbiliaColors.white140,
              width: measures.hourLineWidth,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: measures.hourTextPadding,
              child: Tts(child: Text(hour)),
            ),
            dots,
          ],
        ),
      ),
    );
  }
}

class TimePillarHourDots extends StatelessWidget {
  const TimePillarHourDots({
    required this.hour,
    required this.isNight,
    required this.columnOfDots,
    this.selectionRange,
    Key? key,
  }) : super(key: key);

  final DateTime hour;
  final bool isNight, columnOfDots;
  final SelectionRange? selectionRange;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, DateTime>(
      builder: (context, now) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dotsPerHour,
          (q) {
            final dotTime = hour.copyWith(minute: q * minutesPerDot);
            final dotDuration = dotTime.toDurationFromMidNight();
            if (selectionRange?.inRange(dotDuration) == true) {
              return const AnimatedDot(
                decoration: selectedDotShape,
                duration: Duration(milliseconds: 50),
              );
            }
            if (dotTime.isAfter(now)) {
              if (isNight) {
                return const AnimatedDot(decoration: futureNightDotShape);
              }
              if (columnOfDots) {
                return const AnimatedDot(decoration: currentDotShape);
              }
              return const AnimatedDot(decoration: futureDotShape);
            } else if (now.isBefore(dotTime.add(minutesPerDotDuration))) {
              return const AnimatedDot(decoration: currentDotShape);
            }
            if (isNight) {
              return const AnimatedDot(decoration: pastNightDotShape);
            }
            return const AnimatedDot(decoration: pastDotShape);
          },
        ),
      ),
    );
  }
}
