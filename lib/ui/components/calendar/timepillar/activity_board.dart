import 'dart:math';

import 'package:collection/collection.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityBoard extends StatelessWidget {
  const ActivityBoard(
    this.boardData, {
    required this.categoryMinWidth,
    required this.timepillarWidth,
    Key? key,
  }) : super(key: key);

  final ActivityBoardData boardData;
  final double categoryMinWidth, timepillarWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: max(categoryMinWidth, boardData.columns * timepillarWidth),
      child: Stack(children: boardData.cards),
    );
  }

  static ActivityBoardData positionTimepillarCards(
    List<ActivityOccasion> activities,
    TextStyle textStyle,
    double scaleFactor,
    DayParts dayParts,
    TimepillarSide timepillarSide,
    TimepillarState ts,
    double topMargin,
    double bottomMargin,
  ) {
    final maxEndPos = ts.timePillarHeight +
        topMargin +
        bottomMargin +
        ts.dotDistance +
        ts.minImageHeight +
        ts.padding * 3 +
        (textStyle.fontSize ?? catptionFontSize) *
            (textStyle.height ?? 1.0) *
            ActivityTimepillarCard.maxTitleLines;

    activities.sort((a1, a2) => a1.start.compareTo(a2.start));
    final scheduled = <List<ActivityTimepillarCard>>[];
    final interval = ts.timepillarInterval;
    ActivityLoop:
    for (final ao in activities) {
      final a = ao.activity;

      final minuteStartPosition =
          ao.start.roundToMinute(minutesPerDot, roundingMinute);
      final minuteEndPosition =
          ao.end.roundToMinute(minutesPerDot, roundingMinute);

      final startsBeforeInterval =
          minuteStartPosition.isBefore(interval.startTime);
      final endsAfterInterval = minuteEndPosition.isAfter(interval.endTime);
      final startTime = startsBeforeInterval ? interval.startTime : ao.start;
      final endTime = endsAfterInterval ? interval.endTime : ao.end;

      final dots =
          endTime.difference(startTime).inDots(minutesPerDot, roundingMinute);

      final dotHeight = dots * ts.dotDistance;

      final textHeight = (a.hasTitle
          ? a.title
              .textPainter(textStyle, ts.textWidth, scaleFactor: scaleFactor)
              .height
          : 0.0);
      final imageHeight = a.hasImage || ao.isSignedOff || ao.isPast
          ? ts.minImageHeight + ts.cardPadding
          : 0.0;
      final contentHeight =
          ts.cardPadding + textHeight + imageHeight + ts.cardPadding;
      final renderedHeight = max(contentHeight, ts.minHeight);

      final topOffset = startsBeforeInterval
          ? 0
          : timeToPixels(minuteStartPosition.hour, minuteStartPosition.minute,
                  ts.dotDistance) -
              ts.topOffset(startTime);

      var height = max(dotHeight, renderedHeight);

      if (topOffset + height > maxEndPos) {
        height = maxEndPos - topOffset;
      }

      final top = topOffset + topMargin + ts.topPadding;

      ActivityTimepillarCard card(int col) => ActivityTimepillarCard(
            key: ObjectKey(ao),
            activityOccasion: ao,
            dots: dots,
            top: top,
            column: col,
            height: height,
            textHeight: textHeight,
            textStyle: textStyle,
            timepillarInterval: interval,
            dayParts: dayParts,
            timepillarSide: timepillarSide,
            timepillarState: ts,
          );

      for (var i = 0; i < scheduled.length; i++) {
        final row = scheduled[i];
        if (top > row.last.endPos) {
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
    required this.columns,
  }) : heigth = cards.fold(
            0.0, (previousValue, card) => max(card.endPos, previousValue));
}

enum TimepillarSide {
  right,
  left,
}
