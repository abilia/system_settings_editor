import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

const double timePillarPadding = 4.0,
    timePillarWidth = 42.0,
    timePillarTotalWidth = timePillarWidth + timePillarPadding * 2;

double timePillarHeight(TimepillarInterval interval) =>
    (interval.lengthInHours +
            1) * // include one extra hour for the last digit after the timepillar (could only be the font size of the text)
        hourHeigt +
    TimePillarCalendar.topMargin +
    TimePillarCalendar.bottomMargin;

class TimePillar extends StatelessWidget {
  final TimepillarInterval interval;
  final Occasion dayOccasion;
  final bool showTimeLine;
  final HourClockType hourClockType;
  final List<NightPart> nightParts;
  final DayParts dayParts;
  bool get today => dayOccasion == Occasion.current;

  const TimePillar({
    Key key,
    @required this.interval,
    @required this.dayOccasion,
    @required this.showTimeLine,
    @required this.hourClockType,
    @required this.nightParts,
    @required this.dayParts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dots = today
        ? _todayDots
        : dayOccasion == Occasion.past
            ? _pastDots
            : _futureDots;

    final formatHour = onlyHourFormat(context, clockType: hourClockType);
    final theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.textTheme.headline6.copyWith(color: AbiliaColors.black),
      child: Container(
        color: interval.intervalPart == IntervalPart.NIGHT
            ? TimePillarCalendar.nightBackgroundColor
            : theme.scaffoldBackgroundColor,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            ...nightParts.map((p) {
              return Positioned(
                top: p.start,
                child: SizedBox(
                  width: timePillarTotalWidth,
                  height: p.length,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                        color: TimePillarCalendar.nightBackgroundColor),
                  ),
                ),
              );
            }),
            if (today && showTimeLine)
              Timeline(
                width: timePillarTotalWidth,
                offset: hoursToPixels(interval.startTime.hour) -
                    TimePillarCalendar.topMargin,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(timePillarPadding,
                  TimePillarCalendar.topMargin, timePillarPadding, 0),
              child: SizedBox(
                width: timePillarWidth,
                child: Column(
                  children: List.generate(
                    interval.lengthInHours,
                    (index) {
                      final hourIndex = index + interval.startTime.hour;
                      final hour = interval.startTime
                          .onlyDays()
                          .copyWith(hour: hourIndex);
                      return Hour(
                        hour: formatHour(hour),
                        dots: dots(
                          hour,
                          hour.isNight(dayParts),
                        ),
                        isNight: hour.isNight(dayParts),
                      );
                    },
                  )..add(
                      Hour(
                        hour: formatHour(interval.endTime),
                        dots: SizedBox(
                          width: dotSize,
                          height: dotSize,
                        ),
                        isNight: interval.endTime
                            .subtract(1.hours())
                            .isNight(dayParts),
                      ),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _todayDots(DateTime hour, bool isNight) => TodayDots(
        hour: hour,
        isNight: isNight,
      );

  Widget _pastDots(DateTime hour, bool isNight) => PastDots(
        isNight: isNight,
      );

  Widget _futureDots(DateTime hour, bool isNight) => FutureDots(
        isNight: isNight,
      );
}

class Hour extends StatelessWidget {
  const Hour({
    Key key,
    @required this.hour,
    @required this.dots,
    @required this.isNight,
  }) : super(key: key);

  final String hour;
  final Widget dots;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final dayTheme = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: AbiliaColors.black);
    final nightTheme = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: AbiliaColors.white);
    return Container(
      height: hourHeigt,
      padding: const EdgeInsets.symmetric(vertical: hourPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isNight ? AbiliaColors.white140 : AbiliaColors.black,
            width: hourPadding,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 25.0,
            child: Tts(
              child: Text(
                hour,
                softWrap: false,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.end,
                style: isNight ? nightTheme : dayTheme,
              ),
            ),
          ),
          dots,
        ],
      ),
    );
  }
}
