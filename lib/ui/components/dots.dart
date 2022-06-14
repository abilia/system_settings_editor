import 'dart:math';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

final pastSideDotShape = ShapeDecoration(
  shape: CircleBorder(
    side: BorderSide(
      color: AbiliaColors.black,
      width: layout.borders.dotsThin,
    ),
  ),
);
const pastDotShape = ShapeDecoration(
      shape: CircleBorder(side: BorderSide(color: AbiliaColors.black)),
    ),
    pastNightDotShape = ShapeDecoration(
      shape: CircleBorder(side: BorderSide(color: AbiliaColors.blue)),
    ),
    futureDotShape =
        ShapeDecoration(color: AbiliaColors.black, shape: CircleBorder()),
    transparantDotShape =
        ShapeDecoration(color: Colors.transparent, shape: CircleBorder()),
    currentDotShape =
        ShapeDecoration(color: AbiliaColors.red, shape: CircleBorder()),
    futureNightDotShape =
        ShapeDecoration(color: AbiliaColors.blue, shape: CircleBorder()),
    futureSideDotShape =
        ShapeDecoration(color: AbiliaColors.black, shape: CircleBorder());

class PastDots extends StatelessWidget {
  final bool isNight;
  const PastDots({
    Key? key,
    required this.isNight,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => isNight
      ? const Dots(decoration: pastNightDotShape)
      : const Dots(decoration: pastDotShape);
}

class CurrentDots extends StatelessWidget {
  const CurrentDots({
    Key? key,
    required this.hour,
    required this.isNight,
    required this.columnOfDots,
  }) : super(key: key);

  final DateTime hour;
  final bool isNight, columnOfDots;

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
              if (isNight) {
                return const AnimatedDot(
                  decoration: futureNightDotShape,
                );
              }
              if (columnOfDots) {
                return const AnimatedDot(decoration: currentDotShape);
              }
              return const AnimatedDot(decoration: futureDotShape);
            } else if (now.isBefore(dotTime.add(minutesPerDotDuration))) {
              return const AnimatedDot(decoration: currentDotShape);
            }
            if (isNight) {
              return const AnimatedDot(decoration: pastNightDotShape);
            }
            return const AnimatedDot(decoration: pastDotShape);
          },
        ),
      ),
    );
  }
}

class FutureDots extends StatelessWidget {
  final bool isNight;
  const FutureDots({
    Key? key,
    required this.isNight,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => isNight
      ? const Dots(decoration: futureNightDotShape)
      : const Dots(decoration: futureDotShape);
}

class Dots extends StatelessWidget {
  final Decoration decoration;
  const Dots({Key? key, required this.decoration}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimepillarMeasuresCubit, TimepillarMeasures>(
      buildWhen: (oldState, newState) => oldState.dotSize != newState.dotSize,
      builder: (context, measures) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dotsPerHour,
          (_) => Container(
            height: measures.dotSize,
            width: measures.dotSize,
            decoration: decoration,
          ),
        ),
      ),
    );
  }
}

class AnimatedDot extends StatelessWidget {
  final Decoration? decoration;
  final double? size;
  final Widget? child;
  const AnimatedDot({
    Key? key,
    @required this.decoration,
    this.size,
    this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TimepillarMeasuresCubit, TimepillarMeasures>(
        buildWhen: (previous, current) =>
            size == null && previous.dotSize != current.dotSize,
        builder: (context, measures) => AnimatedContainer(
          duration: transitionDuration,
          height: size ?? measures.dotSize,
          width: size ?? measures.dotSize,
          decoration: decoration,
          child: child,
        ),
      );
}

class SideDots extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final int dots;
  final DayParts dayParts;
  const SideDots({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.dots,
    required this.dayParts,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final flat = startTime.roundToMinute(minutesPerDot, roundingMinute);
    return BlocBuilder<TimepillarMeasuresCubit, TimepillarMeasures>(
      builder: (context, measures) => BlocBuilder<ClockBloc, DateTime>(
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
                if (dotStartTime.isNight(dayParts)) {
                  return const AnimatedDot(decoration: futureNightDotShape);
                }
                return const AnimatedDot(decoration: futureSideDotShape);
              } else if (now.isBefore(nextDotStart)) {
                return const AnimatedDot(decoration: currentDotShape);
              }
              if (dotStartTime.isNight(dayParts)) {
                return const AnimatedDot(decoration: pastNightDotShape);
              }
              return AnimatedDot(decoration: pastSideDotShape);
            },
          ).expand((d) => [d, SizedBox(height: measures.dotPadding)]).toList()
            ..add(SizedBox(width: measures.dotSize)),
        ),
      ),
    );
  }
}

class ActivityInfoSideDots extends StatelessWidget {
  static const int dots = 8, hours = (dots ~/ dotsPerHour);

  final ActivityDay activityDay;
  DateTime get day => activityDay.day;
  Activity get activity => activityDay.activity;
  const ActivityInfoSideDots(this.activityDay, {Key? key}) : super(key: key);
  factory ActivityInfoSideDots.from(
          {required Activity activity, required DateTime day, Key? key}) =>
      ActivityInfoSideDots(ActivityDay(activity, day), key: key);
  @override
  Widget build(BuildContext context) {
    final endTime = activityDay.end;
    final startTime = activityDay.start;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: layout.activityPage.horizontalInfoPadding.left,
      ),
      child: BlocBuilder<ClockBloc, DateTime>(builder: (context, now) {
        final onSameDay = day.isAtSameDay(now),
            notStarted = startTime.isAfter(now),
            isCurrent = activity.hasEndTime &&
                now.inInclusiveRange(startDate: startTime, endDate: endTime);
        final shouldHaveSideDots =
            !activity.fullDay && onSameDay && (notStarted || isCurrent);
        return AnimatedSwitcher(
          duration: ActivityInfo.animationDuration,
          transitionBuilder: (child, animation) => SizeTransition(
            axis: Axis.horizontal,
            axisAlignment: -1,
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          child: shouldHaveSideDots
              ? now.isBefore(startTime)
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
                    )
              : const SizedBox.shrink(),
        );
      }),
    );
  }
}

class SideDotsLarge extends StatelessWidget {
  const SideDotsLarge(
      {Key? key,
      required this.dots,
      required this.startTime,
      required this.endTime,
      required this.now})
      : super(key: key);

  final int dots;
  final DateTime startTime, endTime, now;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.displayTimeLeft != current.displayTimeLeft,
      builder: (context, state) {
        return Column(
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: layout.activityPage.horizontalInfoPadding,
              child: BigDots(
                dots: max(dots, 1),
                startTime: startTime,
                endTime: endTime,
                now: now,
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  if (state.displayTimeLeft)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Tts(
                        child: Text(
                          endTime
                              .difference(now)
                              .toUntilString(Translator.of(context).translate),
                          key: TestKey.sideDotsTimeText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class BigDots extends StatelessWidget {
  final int dots;
  final DateTime startTime, endTime, now;
  const BigDots({
    Key? key,
    required this.dots,
    required this.startTime,
    required this.endTime,
    required this.now,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                padding: EdgeInsets.only(bottom: bigDotPadding), child: dot),
          )
          .toList(),
    );
  }
}

class SubQuarerDot extends StatelessWidget {
  final int minutes;
  const SubQuarerDot({Key? key, required this.minutes}) : super(key: key);

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
  const MiniDot(this.visible, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: transitionDuration,
      margin: const EdgeInsets.all(1.0),
      width: miniDotSize,
      height: miniDotSize,
      decoration: visible ? futureDotShape : transparantDotShape);
}

class OrangeDot extends StatelessWidget {
  const OrangeDot({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ColorDot(
      radius: layout.menuPage.menuItemButton.orangeDotRadius,
      color: AbiliaColors.orange40,
    );
  }
}

class ColorDot extends StatelessWidget {
  final Color color;
  final double radius;
  const ColorDot({
    Key? key,
    this.color = AbiliaColors.white,
    required this.radius,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        color: color,
      ),
    );
  }
}
