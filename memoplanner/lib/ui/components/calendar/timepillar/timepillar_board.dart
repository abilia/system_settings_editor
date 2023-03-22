import 'dart:math';

import 'package:collection/collection.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/ui/all.dart';

class TimepillarBoard extends StatelessWidget {
  const TimepillarBoard(
    this.boardData, {
    required this.categoryMinWidth,
    required this.timepillarWidth,
    required this.textStyle,
    Key? key,
  }) : super(key: key);

  final TimePillarBoardData boardData;
  final TextStyle textStyle;
  final double categoryMinWidth, timepillarWidth;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: textStyle,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
      child: SizedBox(
        width: max(categoryMinWidth, boardData.columns * timepillarWidth),
        child: Stack(children: boardData.cards),
      ),
    );
  }

  static TimePillarBoardData positionTimepillarCards({
    required List<EventOccasion> eventOccasions,
    required TextStyle textStyle,
    required double textScaleFactor,
    required DayParts dayParts,
    required TimepillarSide timepillarSide,
    required TimepillarMeasures measures,
    required double topMargin,
    required double bottomMargin,
    required bool showCategoryColor,
  }) {
    final maxCardHeight = measures.imagePadding.vertical +
        measures.cardImageSize +
        measures.textPadding.top +
        textStyle.fontSize! *
            textStyle.height! *
            TimepillarCard.defaultTitleLines;
    final maxEndPos = topMargin +
        measures.timePillarHeight +
        bottomMargin +
        measures.dotDistance +
        maxCardHeight;

    eventOccasions.sort();
    final scheduled = <List<TimepillarCard>>[];
    ActivityLoop:
    for (final eventOccasion in eventOccasions) {
      final card = eventOccasion is ActivityOccasion
          ? _activityCard(
              activityOccasion: eventOccasion,
              measures: measures,
              textScaleFactor: textScaleFactor,
              maxEndPos: maxEndPos,
              textStyle: textStyle,
              topMargin: topMargin,
              dayParts: dayParts,
              timepillarSide: timepillarSide,
              showCategoryColor: showCategoryColor,
            )
          : eventOccasion is TimerOccasion
              ? _timerCard(
                  timerOccasion: eventOccasion,
                  measures: measures,
                  topMargin: topMargin,
                  maxEndPos: maxEndPos,
                  textStyle: textStyle,
                  textScaleFactor: textScaleFactor,
                )
              : null;
      assert(card != null);
      if (card == null) continue ActivityLoop;

      for (var col = 0; col < scheduled.length; col++) {
        final column = scheduled[col];
        if (card.top > column.last.endPos) {
          column.add(card.builder(col));
          continue ActivityLoop;
        }
      }
      scheduled.add([card.builder(scheduled.length)]);
    }

    return TimePillarBoardData(
      UnmodifiableListView(scheduled.expand((c) => c)),
      columns: scheduled.length,
    );
  }
}

typedef BoardCardBuilder = TimepillarCard Function(int col);

class BoardCardGenerator {
  const BoardCardGenerator({required this.top, required this.builder});
  final BoardCardBuilder builder;
  final double top;
}

BoardCardGenerator _activityCard({
  required ActivityOccasion activityOccasion,
  required TimepillarMeasures measures,
  required double textScaleFactor,
  required double maxEndPos,
  required TextStyle textStyle,
  required double topMargin,
  required DayParts dayParts,
  required TimepillarSide timepillarSide,
  required bool showCategoryColor,
}) {
  final decoration = getCategoryBoxDecoration(
    current: activityOccasion.occasion.isCurrent,
    inactive: activityOccasion.isPast || activityOccasion.isSignedOff,
    showCategoryColor: showCategoryColor,
    category: activityOccasion.activity.category,
    zoom: measures.zoom,
    radius: measures.borderRadius,
  );
  final contentHeight = measures.getContentHeight(
    occasion: activityOccasion,
    decoration: decoration,
    textScaleFactor: textScaleFactor,
    textStyle: textStyle,
  );
  final cardPosition = CardPosition.calculate(
    eventOccasion: activityOccasion,
    measures: measures,
    topMargin: topMargin,
    contentHeight: contentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: true,
  );
  final titleLines = cardPosition.height > contentHeight
      ? TimepillarCard.maxTitleLines
      : TimepillarCard.defaultTitleLines;

  return BoardCardGenerator(
    top: cardPosition.top,
    builder: (int col) => ActivityTimepillarCard(
      key: ObjectKey(activityOccasion),
      activityOccasion: activityOccasion,
      cardPosition: cardPosition,
      column: col,
      dayParts: dayParts,
      timepillarSide: timepillarSide,
      measures: measures,
      decoration: decoration,
      titleLines: titleLines,
    ),
  );
}

BoardCardGenerator _timerCard({
  required TimerOccasion timerOccasion,
  required TimepillarMeasures measures,
  required double topMargin,
  required double maxEndPos,
  required TextStyle textStyle,
  required double textScaleFactor,
}) {
  final decoration = getCategoryBoxDecoration(
    current: timerOccasion.isOngoing,
    inactive: timerOccasion.isPast,
    showCategoryColor: false,
    category: timerOccasion.category,
    zoom: measures.zoom,
    radius: measures.borderRadius,
  );
  final contentHeight = measures.getContentHeight(
    occasion: timerOccasion,
    decoration: decoration,
    textScaleFactor: textScaleFactor,
    textStyle: textStyle,
  );

  final cardPos = CardPosition.calculate(
    eventOccasion: timerOccasion,
    measures: measures,
    topMargin: topMargin,
    contentHeight: contentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: false,
  );

  return BoardCardGenerator(
    top: cardPos.top,
    builder: (int col) => TimerTimepillardCard(
      timerOccasion: timerOccasion,
      measures: measures,
      column: col,
      cardPosition: cardPos,
      decoration: decoration,
    ),
  );
}

class CardPosition {
  final double top, height;
  final int dots;
  const CardPosition(this.top, this.height, this.dots);

  factory CardPosition.calculate({
    required EventOccasion eventOccasion,
    required TimepillarMeasures measures,
    required double topMargin,
    required double contentHeight,
    required double maxEndPos,
    required bool hasSideDots,
  }) {
    final interval = measures.interval;
    final minuteStartPosition =
        eventOccasion.start.roundToMinute(minutesPerDot, roundingMinute);
    final minuteEndPosition =
        eventOccasion.end.roundToMinute(minutesPerDot, roundingMinute);
    final startsBeforeInterval = minuteStartPosition.isBefore(interval.start);
    final endsAfterInterval = minuteEndPosition.isAfter(interval.end);
    final startTime =
        startsBeforeInterval ? interval.start : eventOccasion.start;
    final topOffset = startsBeforeInterval
        ? 0.0
        : timeToPixels(minuteStartPosition.hour, minuteStartPosition.minute,
                measures.dotDistance) -
            measures.topOffset(minuteStartPosition);

    final endTime = endsAfterInterval ? interval.end : eventOccasion.end;
    final dots = hasSideDots
        ? endTime.difference(startTime).inDots(minutesPerDot, roundingMinute)
        : 0;
    final dotHeight = dots * measures.dotDistance;
    var height = max(dotHeight, contentHeight);
    if (topOffset + height > maxEndPos) {
      height = maxEndPos - topOffset;
    }
    final top = topOffset + topMargin + measures.topPadding;
    return CardPosition(top, height, dots);
  }
}

class TimePillarBoardData {
  final UnmodifiableListView<TimepillarCard> cards;
  final double height;
  final int columns;

  TimePillarBoardData(
    this.cards, {
    required this.columns,
  }) : height = cards.map((card) => card.endPos).fold(0.0, max);
}

enum TimepillarSide {
  right,
  left,
}
