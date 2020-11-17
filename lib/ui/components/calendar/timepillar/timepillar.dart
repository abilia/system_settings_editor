import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

double timeToMidDotPixelDistance(DateTime now) =>
    timeToPixels(now.hour, now.minute) + dotSize / 2;
double timeToPixels(int hours, int minutes) =>
    (hours * dotsPerHour + minutes ~/ minutesPerDot) * dotDistance;

const double timePillarPadding = 4.0,
    timePillarWidth = 42.0,
    timePillarTotalWidth = timePillarWidth + timePillarPadding * 2;

double timePillarHeight(TimepillarInterval interval) =>
    interval.lengthInHours * hourHeigt + TimePillarCalendar.topMargin;

class TimePillar extends StatelessWidget {
  final TimepillarInterval interval;
  final Occasion dayOccasion;
  final bool showTimeLine;
  final HourClockType hourClockType;
  bool get today => dayOccasion == Occasion.current;

  const TimePillar({
    Key key,
    @required this.interval,
    @required this.dayOccasion,
    @required this.showTimeLine,
    @required this.hourClockType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dots = today
        ? _todayDots
        : dayOccasion == Occasion.past
            ? (_) => const PastDots()
            : (_) => const FutureDots();

    final formatHour = onlyHourFormat(context, clockType: hourClockType);
    final theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.textTheme.headline6.copyWith(color: AbiliaColors.black),
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(
            top: TimePillarCalendar.topMargin,
          ),
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              if (today && showTimeLine)
                Timeline(
                  width: timePillarTotalWidth,
                  offset: timeToPixels(interval.startTime.hour, 0),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: timePillarPadding),
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
                        return Container(
                          height: hourHeigt,
                          padding:
                              const EdgeInsets.symmetric(vertical: hourPadding),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AbiliaColors.black,
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
                                    formatHour(hour).removeLeadingZeros(),
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                              dots(hour),
                            ],
                          ),
                        );
                      },
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

  Widget _todayDots(DateTime hour) => TodayDots(hour: hour);
}
