import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

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
    final style = Theme.of(context).textTheme.caption;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    final scheduled = positionTimepillarCards(activities, style, scaleFactor);
    return Container(
      width: max(categoryMinWidth,
          scheduled.length * ActivityTimepillarCard.totalWith),
      child: Stack(children: scheduled),
    );
  }

  static List<ActivityTimepillarCard> positionTimepillarCards(
    List<ActivityOccasion> activities,
    TextStyle textStyle,
    double scaleFactor,
  ) {
    activities.sort((a1, a2) => a1.activity
        .startClock(a1.day)
        .compareTo(a2.activity.startClock(a2.day)));
    List<List<ActivityTimepillarCard>> scheduled = [];
    ActivityLoop:
    for (final ao in activities) {
      final a = ao.activity;
      final int dots = a.duration.inDots(minutesPerDot, roundingMinute);
      final dotHeight = dots * dotDistance;

      final textHeight = (a.hasTitle
          ? a.title
              .textSize(textStyle, ActivityTimepillarCard.width,
                  scaleFactor: scaleFactor)
              .height
          : 0.0);
      final imageHeight =
          a.hasImage ? ActivityTimepillarCard.imageSize + 16.0 : 0.0;
      final renderedHeight = textHeight + imageHeight;

      final double height = max(
        max(dotHeight, renderedHeight),
        ActivityTimepillarCard.minHeight,
      );

      final double topOffset = timeToPixelDistanceHour(
        a.startTime.roundToMinute(
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
            textStyle: textStyle,
          );

      for (int i = 0; i < scheduled.length; i++) {
        final row = scheduled[i];
        if (topOffset > row.last.endPos) {
          row.add(card(i));
          continue ActivityLoop;
        }
      }
      scheduled.add([card(scheduled.length)]);
    }
    return scheduled.expand((c) => c).toList();
  }
}
