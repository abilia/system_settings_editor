import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

double timePillarHeight(TimepillarState ts) =>
    (ts.timepillarInterval.lengthInHours +
        1) * // include one extra hour for the last digit after the timepillar (could only be the font size of the text)
    ts.hourHeight;

class TimePillar extends StatelessWidget {
  final TimepillarInterval interval;
  final Occasion dayOccasion;
  final bool use12h;
  final List<NightPart> nightParts;
  final DayParts dayParts;
  final bool columnOfDots;
  final bool preview;
  final double topMargin;

  const TimePillar({
    Key? key,
    required this.interval,
    required this.dayOccasion,
    required this.use12h,
    required this.nightParts,
    required this.dayParts,
    required this.columnOfDots,
    required this.topMargin,
    this.preview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dots = dayOccasion == Occasion.current
        ? _currentDots
        : dayOccasion == Occasion.past
            ? _pastDots
            : _futureDots;

    final formatHour = onlyHourFormat(context, use12h: use12h);
    return BlocBuilder<TimepillarBloc, TimepillarState>(
      builder: (context, ts) => Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ...nightParts.map(
            (p) {
              return Positioned(
                top: p.start,
                child: SizedBox(
                  width: ts.timePillarTotalWidth,
                  height: p.length,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                        color: TimepillarCalendar.nightBackgroundColor),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              ts.timePillarPadding,
              topMargin,
              ts.timePillarPadding,
              0,
            ),
            child: SizedBox(
              width: ts.timePillarWidth,
              child: Column(
                children: [
                  ...List.generate(
                    interval.lengthInHours,
                    (index) {
                      final hourIndex = index + interval.startTime.hour;
                      final hour = interval.startTime
                          .onlyDays()
                          .copyWith(hour: hourIndex);
                      final isNight = hour.isNight(dayParts);
                      return Hour(
                        hour: formatHour(hour),
                        dots: dots(
                          hour,
                          isNight,
                          columnOfDots,
                        ),
                        isNight: isNight,
                        timepillarState: ts,
                      );
                    },
                  ),
                  if (!preview)
                    Hour(
                      hour: formatHour(interval.endTime),
                      dots: SizedBox(
                        width: ts.dotSize,
                        height: ts.dotSize,
                      ),
                      isNight: interval.endTime
                          .subtract(1.hours())
                          .isNight(dayParts),
                      timepillarState: ts,
                    ),
                ],
              ),
            ),
          ),
        ],
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
    Key? key,
    required this.hour,
    required this.dots,
    required this.isNight,
    required this.timepillarState,
  }) : super(key: key);

  final String hour;
  final Widget dots;
  final bool isNight;
  final TimepillarState timepillarState;

  @override
  Widget build(BuildContext context) {
    final h6 = Theme.of(context).textTheme.headline6 ?? headline6;
    final fontSize = h6.fontSize ?? headline6FontSize;
    final ts = timepillarState;

    return DefaultTextStyle(
      style: h6.copyWith(
        color: isNight ? AbiliaColors.white : AbiliaColors.black,
        fontSize: fontSize * ts.zoom,
      ),
      child: Container(
        height: ts.hourHeight,
        padding: EdgeInsets.symmetric(vertical: ts.hourPadding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isNight ? AbiliaColors.white140 : AbiliaColors.black,
              width: ts.hourPadding,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Tts(
                child: Text(
                  hour,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            dots,
          ],
        ),
      ),
    );
  }
}
