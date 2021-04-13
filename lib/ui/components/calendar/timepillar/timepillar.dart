import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

double timePillarHeight(TimepillarState ts) =>
    (ts.timepillarInterval.lengthInHours +
            1) * // include one extra hour for the last digit after the timepillar (could only be the font size of the text)
        ts.hourHeight +
    TimepillarCalendar.topMargin +
    TimepillarCalendar.bottomMargin;

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
    return BlocBuilder<TimepillarBloc, TimepillarState>(
      builder: (context, ts) => DefaultTextStyle(
        style: theme.textTheme.headline6.copyWith(color: AbiliaColors.black),
        child: Container(
          color: interval.intervalPart == IntervalPart.NIGHT
              ? TimepillarCalendar.nightBackgroundColor
              : theme.scaffoldBackgroundColor,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              ...nightParts.map((p) {
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
              }),
              if (today && showTimeLine)
                Timeline(
                  width: ts.timePillarTotalWidth,
                  timepillarState: ts,
                  offset:
                      hoursToPixels(interval.startTime.hour, ts.dotDistance) -
                          TimepillarCalendar.topMargin,
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(ts.timePillarPadding,
                    TimepillarCalendar.topMargin, ts.timePillarPadding, 0),
                child: SizedBox(
                  width: ts.timePillarWidth,
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
                          timepillarState: ts,
                        );
                      },
                    )..add(
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
                      ),
                  ),
                ),
              ),
            ],
          ),
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
    @required this.timepillarState,
  }) : super(key: key);

  final String hour;
  final Widget dots;
  final bool isNight;
  final TimepillarState timepillarState;

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.headline6.fontSize;
    final ts = timepillarState;
    final dayTheme = Theme.of(context).textTheme.headline6.copyWith(
          color: AbiliaColors.black,
          fontSize: fontSize * ts.zoom,
        );
    final nightTheme = Theme.of(context).textTheme.headline6.copyWith(
          color: AbiliaColors.white,
          fontSize: fontSize * ts.zoom,
        );
    return Container(
      height: context.read<TimepillarBloc>().state.hourHeight,
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
            width: 25.0.s * ts.zoom,
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
