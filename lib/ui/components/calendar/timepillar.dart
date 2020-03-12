import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils/all.dart';

const _pastDotShape = ShapeDecoration(shape: CircleBorder(side: BorderSide())),
    _futureDotShape =
        ShapeDecoration(color: AbiliaColors.black, shape: CircleBorder()),
    _currentDotShape =
        ShapeDecoration(color: AbiliaColors.red, shape: CircleBorder());
const int dotsPerHour = 4, minutesPerDot = 60 ~/ dotsPerHour;
const double dotSize = 10.0,
    hourPadding = 1.0,
    dotPadding = hourPadding * 3,
    timePillarPadding = 4.0,
    timePillarWidth = 42.0,
    timePillarTotalWidth = 42.0 + timePillarPadding * 2,
    hourHeigt = (dotSize + dotPadding) * dotsPerHour,
    scrollHeight = hourHeigt * 24;

class TimePillar extends StatelessWidget {
  final DateTime day;
  final Occasion dayOccasion;

  const TimePillar({
    Key key,
    @required this.day,
    @required this.dayOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget Function(DateTime) dots = dayOccasion == Occasion.current
        ? _todayDots
        : dayOccasion == Occasion.past
            ? (_) => const PastDots()
            : (_) => const FutureDots();
    return DefaultTextStyle(
      style:
          Theme.of(context).textTheme.title.copyWith(color: AbiliaColors.black),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: timePillarPadding),
        child: SizedBox(
          width: timePillarWidth,
          child: Column(
            children: List.generate(
              24,
              (hourIndex) {
                final hour = day.copyWith(hour: hourIndex);
                return Container(
                  height: hourHeigt,
                  padding: const EdgeInsets.symmetric(vertical: hourPadding),
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
    );
  }

  String _formatHour(DateTime hour) {
    final hourFormatedText =
        DateFormat('j', Locale.cachedLocaleString).format(hour);
    final withoutLeadingZeroOrTrailingAmPm =
        hourFormatedText.substring(hourFormatedText.startsWith('0') ? 1 : 0, 2);
    return withoutLeadingZeroOrTrailingAmPm;
  }

  BlocBuilder<ClockBloc, DateTime> _todayDots(DateTime hour) =>
      BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dotsPerHour,
            (q) {
              final dotTime = hour.copyWith(minute: q * minutesPerDot);
              if (dotTime.isAfter(now)) return const FutureDot();
              final nextDotTime = dotTime.add(minutesPerDot.minutes());
              if (now.isBefore(nextDotTime)) return const CurrentDot();
              return const PastDot();
            },
          ),
        ),
      );
}

class PastDots extends StatelessWidget {
  const PastDots({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => const Dots(decoration: _pastDotShape);
}

class FutureDots extends StatelessWidget {
  const FutureDots({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Dots(decoration: _futureDotShape);
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
        duration: 2.seconds(),
        height: dotSize,
        width: dotSize,
        decoration: decoration,
      );
}

class FutureDot extends StatelessWidget {
  const FutureDot({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const AnimatedDot(decoration: _futureDotShape);
}

class PastDot extends StatelessWidget {
  const PastDot({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const AnimatedDot(decoration: _pastDotShape);
}

class CurrentDot extends StatelessWidget {
  const CurrentDot({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const AnimatedDot(decoration: _currentDotShape);
}
