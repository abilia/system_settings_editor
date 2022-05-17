import 'dart:math';

import 'package:collection/collection.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

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
      maxLines: TimepillarCard.maxTitleLines,
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
  }) {
    final maxCardHeight = measures.cardPadding.vertical +
        measures.cardMinImageHeight +
        measures.cardPadding.top +
        textStyle.fontSize! * textStyle.height! * TimepillarCard.maxTitleLines;
    final maxEndPos = topMargin +
        measures.timePillarHeight +
        bottomMargin +
        measures.dotDistance +
        maxCardHeight;

    eventOccasions.sort((a1, a2) => a1.start.compareTo(a2.start));
    final scheduled = <List<TimepillarCard>>[];
    ActivityLoop:
    for (final eo in eventOccasions) {
      final cardGenerator = eo is ActivityOccasion
          ? _activityCard(
              activityOccasion: eo,
              measures: measures,
              textScaleFactor: textScaleFactor,
              maxEndPos: maxEndPos,
              textStyle: textStyle,
              topMargin: topMargin,
              dayParts: dayParts,
              timepillarSide: timepillarSide,
            )
          : eo is TimerOccasion
              ? _timerCard(
                  timerOccasion: eo,
                  measures: measures,
                  topMargin: topMargin,
                  maxEndPos: maxEndPos,
                  textStyle: textStyle,
                  textScaleFactor: textScaleFactor,
                )
              : null;
      assert(cardGenerator != null);
      if (cardGenerator == null) continue ActivityLoop;

      for (var col = 0; col < scheduled.length; col++) {
        final column = scheduled[col];
        if (cardGenerator.top > column.last.endPos) {
          column.add(cardGenerator.builder(col));
          continue ActivityLoop;
        }
      }
      scheduled.add([cardGenerator.builder(scheduled.length)]);
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
}) {
  final a = activityOccasion.activity;
  final textHeight = (a.hasTitle
      ? a.title
          .textPainter(textStyle, measures.cardTextWidth,
              scaleFactor: textScaleFactor)
          .height
      : 0.0);
  final imageHeight =
      a.hasImage || activityOccasion.isSignedOff || activityOccasion.isPast
          ? measures.cardMinImageHeight + measures.cardPadding.top
          : 0.0;
  final contentHeight =
      measures.cardPadding.vertical + textHeight + imageHeight;
  final cardPosition = CardPosition.calculate(
    eventOccasion: activityOccasion,
    measures: measures,
    topMargin: topMargin,
    contentHeight: contentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: true,
    minHeight: measures.activityCardMinHeight,
  );

  return BoardCardGenerator(
    top: cardPosition.top,
    builder: (int col) => ActivityTimepillarCard(
      key: ObjectKey(activityOccasion),
      activityOccasion: activityOccasion,
      cardPosition: cardPosition,
      column: col,
      textHeight: textHeight,
      dayParts: dayParts,
      timepillarSide: timepillarSide,
      measures: measures,
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
  final contentHeight = timerOccasion.hasImage
      ? measures.cardMinImageHeight
      : timerOccasion.timer.title
          .textPainter(textStyle, measures.cardTextWidth,
              scaleFactor: textScaleFactor)
          .height;

  final totalContentHeight = measures.cardPadding.vertical +
      measures.timerWheelPadding.vertical +
      measures.timerWheelSize.height +
      contentHeight;

  final cardPos = CardPosition.calculate(
    eventOccasion: timerOccasion,
    measures: measures,
    topMargin: topMargin,
    contentHeight: totalContentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: false,
    minHeight: measures.timerMinHeight,
  );

  return BoardCardGenerator(
    top: cardPos.top,
    builder: (int col) => TimerTimepillardCard(
      timerOccasion: timerOccasion,
      measures: measures,
      column: col,
      cardPosition: cardPos,
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
    required double minHeight,
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
            measures.topOffset(startTime);

    final endTime = endsAfterInterval ? interval.end : eventOccasion.end;
    final dots = hasSideDots
        ? endTime.difference(startTime).inDots(minutesPerDot, roundingMinute)
        : 0;
    final dotHeight = dots * measures.dotDistance;
    final renderedHeight = max(contentHeight, minHeight);
    var height = max(dotHeight, renderedHeight);
    if (topOffset + height > maxEndPos) {
      height = maxEndPos - topOffset;
    }
    final top = topOffset + topMargin + measures.topPadding;
    return CardPosition(top, height, dots);
  }
}

class TimePillarBoardData {
  final UnmodifiableListView<TimepillarCard> cards;
  final double heigth;
  final int columns;

  TimePillarBoardData(
    this.cards, {
    required this.columns,
  }) : heigth = cards.map((card) => card.endPos).fold(0.0, max);
}

enum TimepillarSide {
  right,
  left,
}
