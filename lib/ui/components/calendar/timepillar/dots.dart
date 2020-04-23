import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/calendar/timepillar/all.dart';

const int dotsPerHour = 4,
    minutesPerDot = 60 ~/ dotsPerHour,
    roundingMinute = minutesPerDot ~/ 2;
const double dotSize = 10.0,
    hourPadding = 1.0,
    dotPadding = hourPadding * 3,
    dotDistance = dotSize + dotPadding,
    hourHeigt = dotDistance * dotsPerHour;

const pastDotShape = ShapeDecoration(shape: CircleBorder(side: BorderSide())),
    futureDotShape =
        ShapeDecoration(color: AbiliaColors.black, shape: CircleBorder()),
    currentDotShape =
        ShapeDecoration(color: AbiliaColors.red, shape: CircleBorder());
final futureSideDotShape = ShapeDecoration(
        color: AbiliaColors.transparentBlack[20], shape: CircleBorder()),
    pastSideDotShape = ShapeDecoration(
  shape: CircleBorder(
    side: BorderSide(
      color: AbiliaColors.transparentBlack[20],
    ),
  ),
);

class PastDots extends StatelessWidget {
  const PastDots({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => const Dots(decoration: pastDotShape);
}

class TodayDots extends StatelessWidget {
  const TodayDots({
    Key key,
    @required this.hour,
  }) : super(key: key);

  final DateTime hour;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => Column(
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
      ),
    );
  }
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

class SideDots extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final int dots;
  const SideDots({
    Key key,
    @required this.startTime,
    @required this.endTime,
    @required this.dots,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final flat = startTime.roundDownToMinute(minutesPerDot);
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (_, now) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dots,
          (dot) {
            final dotStartTime = dot == 0
                ? startTime
                : flat.add((dot * minutesPerDot).minutes());
            final nextDotStart = dot < dots - 1
                ? flat.add(((dot + 1) * minutesPerDot).minutes())
                : endTime.add(1.minutes());
            if (dotStartTime.isAfter(now)) {
              return AnimatedDot(decoration: futureSideDotShape);
            } else if (now.isBefore(nextDotStart)) {
              return const AnimatedDot(decoration: currentDotShape);
            }
            return AnimatedDot(decoration: pastSideDotShape);
          },
        ).expand((d) => [d, const SizedBox(height: dotPadding)]).toList()
          ..add(const SizedBox(width: dotSize)),
      ),
    );
  }
}
