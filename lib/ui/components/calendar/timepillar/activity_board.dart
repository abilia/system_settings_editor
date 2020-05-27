import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

class ActivityBoard extends StatelessWidget {
  const ActivityBoard(
    this.boardData, {
    @required this.categoryMinWidth,
    Key key,
  }) : super(key: key);

  final ActivityBoardData boardData;
  final double categoryMinWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: max(categoryMinWidth,
          boardData.columns * ActivityTimepillarCard.totalWith),
      child: Stack(children: boardData.cards),
    );
  }

  static ActivityBoardData positionTimepillarCards(
    List<ActivityOccasion> activities,
    TextStyle textStyle,
    double scaleFactor,
  ) {
    final maxEndPos = timePillarHeight +
        dotDistance +
        ActivityTimepillarCard.imageHeigth +
        ActivityTimepillarCard.padding * 2 +
        textStyle.fontSize *
            textStyle.height *
            ActivityTimepillarCard.maxTitleLines;

    activities.sort((a1, a2) => a1.activity
        .startClock(a1.day)
        .compareTo(a2.activity.startClock(a2.day)));
    final scheduled = <List<ActivityTimepillarCard>>[];
    ActivityLoop:
    for (final ao in activities) {
      final a = ao.activity;
      final dots = a.duration.inDots(minutesPerDot, roundingMinute);
      final dotHeight = dots * dotDistance;

      final textHeight = (a.hasTitle
          ? a.title
              .textSize(textStyle, ActivityTimepillarCard.width,
                  scaleFactor: scaleFactor)
              .height
          : 0.0);
      final imageHeight = a.hasImage || a.isSignedOff(ao.day)
          ? ActivityTimepillarCard.imageHeigth
          : 0.0;
      final renderedHeight =
          max(textHeight + imageHeight, ActivityTimepillarCard.minHeight);

      final minutePosition =
          a.startTime.roundToMinute(minutesPerDot, roundingMinute);

      final topOffset = minutePosition.isDayAfter(a.startTime)
          ? timeToPixelDistance(24, 0)
          : timeToPixelDistanceHour(minutePosition);

      var height = max(dotHeight, renderedHeight);

      if (topOffset + height > maxEndPos) {
        height = maxEndPos - topOffset;
      }

      Widget card(int col) => ActivityTimepillarCard(
            key: ObjectKey(ao),
            activityOccasion: ao,
            dots: dots,
            top: topOffset,
            column: col,
            height: height,
            textStyle: textStyle,
          );

      for (var i = 0; i < scheduled.length; i++) {
        final row = scheduled[i];
        if (topOffset > row.last.endPos) {
          row.add(card(i));
          continue ActivityLoop;
        }
      }
      scheduled.add([card(scheduled.length)]);
    }

    return ActivityBoardData(
      UnmodifiableListView(scheduled.expand((c) => c)),
      columns: scheduled.length,
    );
  }
}

class ActivityBoardData {
  final UnmodifiableListView<ActivityTimepillarCard> cards;
  final double heigth;
  final int columns;

  ActivityBoardData(
    this.cards, {
    this.columns,
  }) : heigth = cards.fold(
            0.0, (previousValue, card) => max(card.endPos, previousValue));
}
