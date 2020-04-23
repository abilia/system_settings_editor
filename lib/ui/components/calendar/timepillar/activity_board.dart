import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/calendar/timepillar/all.dart';

class ActivityBoard extends StatelessWidget {
  const ActivityBoard({
    Key key,
    @required this.categoryMinWidth,
    @required this.activities,
  }) : super(key: key);

  final double categoryMinWidth;
  final List<ActivityOccasion> activities;

  @override
  Widget build(BuildContext context) {
    final schedualed = positionTimepillarCards(activities);
    return Container(
      width: max(categoryMinWidth,
          schedualed.length * ActivityTimepillarCard.totalWith),
      child: Stack(children: schedualed),
    );
  }

  static List<ActivityTimepillarCard> positionTimepillarCards(
      List<ActivityOccasion> activities) {
    activities.sort((a1, a2) => a1.activity
        .startClock(a1.day)
        .compareTo(a2.activity.startClock(a2.day)));
    List<List<ActivityTimepillarCard>> schedualed = [];
    ActivityLoop:
    for (final ao in activities) {
      final int dots = ao.activity.duration
          .milliseconds()
          .inDots(minutesPerDot, roundingMinute);
      final double height =
          max(dots * dotDistance, ActivityTimepillarCard.minHeight);
      final double topOffset = timeToPixelDistanceHour(
        ao.activity.start.roundToMinute(
          minutesPerDot,
          roundingMinute,
        ),
      );
      card(int col) => ActivityTimepillarCard(
            key: ObjectKey(ao),
            activityOccasion: ao,
            dots: dots,
            top: topOffset,
            column: col,
            height: height,
          );

      for (int i = 0; i < schedualed.length; i++) {
        final row = schedualed[i];
        if (topOffset > row.last.endPos) {
          row.add(card(i));
          continue ActivityLoop;
        }
      }
      schedualed.add([card(schedualed.length)]);
    }
    return schedualed.expand((c) => c).toList();
  }
}
