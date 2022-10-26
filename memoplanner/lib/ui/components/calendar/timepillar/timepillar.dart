import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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

  const TimePillar({
    required this.interval,
    required this.dayOccasion,
    required this.use12h,
    required this.nightParts,
    required this.dayParts,
    required this.columnOfDots,
    required this.topMargin,
    required this.measures,
    this.preview = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dots = dayOccasion == Occasion.current
        ? _currentDots
        : dayOccasion == Occasion.past
            ? _pastDots
            : _futureDots;

    final formatHour = onlyHourFormat(context, use12h: use12h);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        measures.timePillarPadding,
        topMargin,
        measures.timePillarPadding,
        0,
      ),
      child: SizedBox(
        width: measures.timePillarWidth,
        child: Column(
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
                  dots: dots(
                    hour,
                    isNight,
                    columnOfDots,
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
      ),
    );
  }

  Widget _currentDots(DateTime hour, bool isNight, bool columnOfDots) =>
      CurrentDots(
        hour: hour,
        isNight: isNight,
        columnOfDots: columnOfDots,
      );

  Widget _pastDots(_, bool isNight, __) => PastDots(isNight: isNight);

  Widget _futureDots(_, bool isNight, __) => FutureDots(isNight: isNight);
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
              color: isNight ? AbiliaColors.white140 : AbiliaColors.white140,
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
