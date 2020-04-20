import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:intl/intl.dart';
import 'package:seagull/ui/components/calendar/timepillar/all.dart';
import 'package:seagull/utils/all.dart';

const pastDotShape = ShapeDecoration(shape: CircleBorder(side: BorderSide())),
    futureDotShape =
        ShapeDecoration(color: AbiliaColors.black, shape: CircleBorder()),
    currentDotShape =
        ShapeDecoration(color: AbiliaColors.red, shape: CircleBorder());

double timeToPixelDistance(DateTime now) =>
    (now.hour * dotsPerHour + now.minute ~/ minutesPerDot) * dotDistance +
    hourPadding +
    dotSize / 2;
const int dotsPerHour = 4, minutesPerDot = 60 ~/ dotsPerHour;
const double dotSize = 10.0,
    hourPadding = 1.0,
    dotPadding = hourPadding * 3,
    dotDistance = dotSize + dotPadding,
    timePillarPadding = 4.0,
    timePillarWidth = 42.0,
    timePillarTotalWidth = timePillarWidth + timePillarPadding * 2,
    hourHeigt = dotDistance * dotsPerHour,
    scrollHeight = hourHeigt * 24;
const transitionDuration = Duration(seconds: 1);

class TimePillar extends StatelessWidget {
  final DateTime day;
  final Occasion dayOccasion;
  final DateTime now;
  bool get today => dayOccasion == Occasion.current;

  const TimePillar({
    Key key,
    @required this.day,
    @required this.dayOccasion,
    @required this.now,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget Function(DateTime) dots = today
        ? _todayDots
        : dayOccasion == Occasion.past
            ? (_) => const PastDots()
            : (_) => const FutureDots();
    final theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.textTheme.title.copyWith(color: AbiliaColors.black),
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          children: <Widget>[
            if (today)
              Timeline(
                now: now,
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
                                _formatHour(hour),
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

  String _formatHour(DateTime hour) {
    final hourFormatedText =
        DateFormat('j', Locale.cachedLocaleString).format(hour);
    final withoutLeadingZeroOrTrailingAmPm =
        hourFormatedText.substring(hourFormatedText.startsWith('0') ? 1 : 0, 2);
    return withoutLeadingZeroOrTrailingAmPm;
  }

  Widget _todayDots(DateTime hour) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dotsPerHour,
          (q) {
            final dotTime = hour.copyWith(minute: q * minutesPerDot);
            if (dotTime.isAfter(now)) {
              return const AnimatedDot(decoration: futureDotShape);
            } else if (now.isBefore(dotTime.add(minutesPerDot.minutes()))) {
              return const AnimatedDot(decoration: currentDotShape);
            }
            return const AnimatedDot(decoration: pastDotShape);
          },
        ),
      );
}

class PastDots extends StatelessWidget {
  const PastDots({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => const Dots(decoration: pastDotShape);
}

class FutureDots extends StatelessWidget {
  const FutureDots({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Dots(decoration: futureDotShape);
}

class Dots extends StatelessWidget {
  final Decoration decoration;
  const Dots({Key key, @required this.decoration}) : super(key: key);
  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dotsPerHour,
          (_) => Container(
            height: dotSize,
            width: dotSize,
            decoration: decoration,
          ),
        ),
      );
}

class AnimatedDot extends StatelessWidget {
  final Decoration decoration;
  const AnimatedDot({Key key, @required this.decoration}) : super(key: key);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: transitionDuration,
        height: dotSize,
        width: dotSize,
        decoration: decoration,
      );
}
