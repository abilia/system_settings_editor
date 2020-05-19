import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/models/category.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/calendar/timepillar/all.dart';

const int dotsPerHour = 4,
    minutesPerDot = 60 ~/ dotsPerHour,
    minutePerSubDot = minutesPerDot ~/ 5,
    roundingMinute = minutesPerDot ~/ 2;
const double dotSize = 10.0,
    bigDotSize = 28.0,
    miniDotSize = 4.0,
    hourPadding = 1.0,
    dotPadding = hourPadding * 3,
    bigDotPadding = 6.0,
    dotDistance = dotSize + dotPadding,
    hourHeigt = dotDistance * dotsPerHour;

const pastDotShape = ShapeDecoration(shape: CircleBorder(side: BorderSide())),
    futureDotShape =
        ShapeDecoration(color: AbiliaColors.black, shape: CircleBorder()),
    transparantDotShape =
        ShapeDecoration(color: Colors.transparent, shape: CircleBorder()),
    currentDotShape =
        ShapeDecoration(color: AbiliaColors.red, shape: CircleBorder()),
    futureSideDotShape = ShapeDecoration(
        color: AbiliaColors.transparentBlack20, shape: CircleBorder()),
    pastSideDotShape = ShapeDecoration(
  shape: CircleBorder(
    side: BorderSide(
      color: AbiliaColors.transparentBlack20,
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
  final double size;
  final Widget child;
  const AnimatedDot({Key key, @required this.decoration, this.size, this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: transitionDuration,
        height: size ?? dotSize,
        width: size ?? dotSize,
        decoration: decoration,
        child: child,
      );
}

class SideTime extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final Occasion occasion;
  final int category;
  final double height;
  const SideTime({
    Key key,
    @required this.startTime,
    @required this.endTime,
    @required this.occasion,
    @required this.category,
    @required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeDiff = startTime.difference(endTime).abs();
    final height = timeDiff.inMinutes * (hourHeigt / 60);
    return SizedBox(
      width: dotSize,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: colorFromOccastion(occasion),
            borderRadius: category == Category.left ? onlyRight : onlyLeft),
      ),
    );
  }

  Color colorFromOccastion(Occasion occasion) {
    switch (occasion) {
      case Occasion.current:
        return AbiliaColors.red;
      case Occasion.past:
        return AbiliaColors.white120;
      case Occasion.future:
        return AbiliaColors.green;
      default:
        return AbiliaColors.green;
    }
  }
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
    final flat = startTime.roundToMinute(minutesPerDot, roundingMinute);
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
              return const AnimatedDot(decoration: futureSideDotShape);
            } else if (now.isBefore(nextDotStart)) {
              return const AnimatedDot(decoration: currentDotShape);
            }
            return const AnimatedDot(decoration: pastSideDotShape);
          },
        ).expand((d) => [d, const SizedBox(height: dotPadding)]).toList()
          ..add(const SizedBox(width: dotSize)),
      ),
    );
  }
}

class ActivityInfoSideDots extends StatelessWidget {
  static const int dots = 8, hours = (dots ~/ dotsPerHour);

  final Activity activity;
  final DateTime day;
  const ActivityInfoSideDots({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final endTime = activity.endClock(day);
    final startTime = activity.startClock(day);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: ActivityInfo.margin),
      child: BlocBuilder<ClockBloc, DateTime>(builder: (context, now) {
        final onSameDay = day.isAtSameDay(now),
            notStarted = startTime.isAfter(now),
            isCurrent = activity.hasEndTime &&
                now.isOnOrBetween(startDate: startTime, endDate: endTime);
        final shouldHaveSideDots =
            !activity.fullDay && onSameDay && (notStarted || isCurrent);
        return AnimatedSwitcher(
          duration: ActivityInfo.animationDuration,
          child: !shouldHaveSideDots
              ? const SizedBox()
              : now.isBefore(startTime)
                  ? SideDotsLarge(
                      dots: dots,
                      startTime: startTime.subtract(hours.hours()),
                      endTime: startTime,
                      now: now,
                    )
                  : SideDotsLarge(
                      dots: dots,
                      startTime: startTime,
                      endTime: endTime,
                      now: now,
                    ),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              axis: Axis.horizontal,
              axisAlignment: -1,
              child: FadeTransition(
                child: child,
                opacity: animation,
              ),
              sizeFactor: animation,
            );
          },
        );
      }),
    );
  }
}

class SideDotsLarge extends StatelessWidget {
  const SideDotsLarge(
      {Key key,
      @required this.dots,
      @required this.startTime,
      @required this.endTime,
      @required this.now})
      : super(key: key);

  final int dots;
  final DateTime startTime, endTime, now;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Spacer(),
        BigDots(
          dots: max(dots, 1),
          startTime: startTime,
          endTime: endTime,
          now: now,
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              if (endTime.isAtSameMomentOrAfter(now))
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    endTime
                        .difference(now)
                        .toUntilString(Translator.of(context).translate),
                    textAlign: TextAlign.center,
                  ),
                ),
              Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

class BigDots extends StatelessWidget {
  final int dots;
  final DateTime startTime, endTime, now;
  const BigDots({
    Key key,
    @required this.dots,
    @required this.startTime,
    @required this.endTime,
    @required this.now,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ActivityInfo.margin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(dots, (dot) {
          if (dot == 0) {
            final timeLeft = endTime.difference(now).inMinutes;
            return SubQuarerDot(minutes: timeLeft);
          }
          final dotEndTime =
              endTime.subtract((dot * (minutesPerDot + 1)).minutes());
          final past = now.isAtSameMomentOrAfter(dotEndTime);
          final decoration = past ? pastDotShape : futureDotShape;
          return AnimatedDot(decoration: decoration, size: bigDotSize);
        })
            .reversed
            .map(
              (dot) => Padding(
                  padding: const EdgeInsets.only(bottom: bigDotPadding),
                  child: dot),
            )
            .toList(),
      ),
    );
  }
}

class SubQuarerDot extends StatelessWidget {
  final int minutes;
  const SubQuarerDot({Key key, @required this.minutes}) : super(key: key);

  @override
  Widget build(BuildContext context) => minutes > minutesPerDot
      ? AnimatedDot(decoration: futureDotShape, size: bigDotSize)
      : AnimatedDot(
          size: bigDotSize,
          decoration: pastDotShape,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              dot(2),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  dot(3),
                  dot(0),
                  dot(1),
                ],
              ),
              dot(4)
            ],
          ),
        );
  Widget dot(int i) => MiniDot(minutes > (minutePerSubDot * i));
}

class MiniDot extends StatelessWidget {
  final bool visible;
  const MiniDot(this.visible);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: transitionDuration,
      margin: const EdgeInsets.all(1.0),
      width: miniDotSize,
      height: miniDotSize,
      decoration: visible ? futureDotShape : transparantDotShape);
}
