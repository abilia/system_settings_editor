import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

double timeToPixelDistance(DateTime now) =>
    (now.hour * dotsPerHour + now.minute ~/ minutesPerDot) * dotDistance +
    hourPadding;
double timeToMidDotPixelDistance(DateTime now) =>
    timeToPixelDistance(now) + dotSize / 2;
double timeToPixelDistanceHour(DateTime now) =>
    timeToPixelDistance(now) + hourPadding;

const double timePillarPadding = 4.0,
    timePillarWidth = 42.0,
    timePillarTotalWidth = timePillarWidth + timePillarPadding * 2,
    scrollHeight = hourHeigt * 24;

class TimePillar extends StatelessWidget {
  final DateTime day;
  final Occasion dayOccasion;
  bool get today => dayOccasion == Occasion.current;

  const TimePillar({
    Key key,
    @required this.day,
    @required this.dayOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget Function(DateTime) dots = today
        ? _todayDots
        : dayOccasion == Occasion.past
            ? (_) => const PastDots()
            : (_) => const FutureDots();

    final formatHour = onlyHourFormat(context);
    final theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.textTheme.title.copyWith(color: AbiliaColors.black),
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            if (today)
              Timeline(
                width: timePillarTotalWidth,
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: timePillarPadding),
              child: SizedBox(
                width: timePillarWidth,
                child: Column(
                  children: List.generate(
                    24,
                    (hourIndex) {
                      final hour = day.copyWith(hour: hourIndex);
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
                              child: Text(
                                formatHour(hour).removeLeadingZeros(),
                                textAlign: TextAlign.end,
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
    );
  }

  Widget _todayDots(DateTime hour) => TodayDots(hour: hour);
}
