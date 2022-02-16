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
    required TimepillarState timepillarState,
    required double topMargin,
    required double bottomMargin,
  }) {
    final maxCardHeight = timepillarState.cardPadding.vertical +
        timepillarState.cardMinImageHeight +
        timepillarState.cardPadding.top +
        textStyle.fontSize! * textStyle.height! * TimepillarCard.maxTitleLines;
    final maxEndPos = topMargin +
        timepillarState.timePillarHeight +
        bottomMargin +
        timepillarState.dotDistance +
        maxCardHeight;

    eventOccasions.sort((a1, a2) => a1.start.compareTo(a2.start));
    final scheduled = <List<TimepillarCard>>[];
    ActivityLoop:
    for (final eo in eventOccasions) {
      final cardGenerator = eo is ActivityOccasion
          ? _activityCard(
              activityOccasion: eo,
              timepillarState: timepillarState,
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
                  timepillarState: timepillarState,
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
  required TimepillarState timepillarState,
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
          .textPainter(textStyle, timepillarState.cardTextWidth,
              scaleFactor: textScaleFactor)
          .height
      : 0.0);
  final imageHeight =
      a.hasImage || activityOccasion.isSignedOff || activityOccasion.isPast
          ? timepillarState.cardMinImageHeight + timepillarState.cardPadding.top
          : 0.0;
  final contentHeight =
      timepillarState.cardPadding.vertical + textHeight + imageHeight;
  final cardPosition = CardPosition.calculate(
    eventOccasion: activityOccasion,
    timepillarState: timepillarState,
    topMargin: topMargin,
    contentHeight: contentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: true,
    minHeight: timepillarState.activityCardMinHeight,
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
      timepillarState: timepillarState,
    ),
  );
}

BoardCardGenerator _timerCard({
  required TimerOccasion timerOccasion,
  required TimepillarState timepillarState,
  required double topMargin,
  required double maxEndPos,
  required TextStyle textStyle,
  required double textScaleFactor,
}) {
  final contentHeight = timerOccasion.hasImage
      ? timepillarState.cardMinImageHeight
      : timerOccasion.timer.title
          .textPainter(textStyle, timepillarState.cardTextWidth,
              scaleFactor: textScaleFactor)
          .height;

  final totalContentHeight = timepillarState.cardPadding.vertical +
      timepillarState.timerWheelPadding.vertical +
      timepillarState.timerWheelSize.height +
      contentHeight;

  final cardPos = CardPosition.calculate(
    eventOccasion: timerOccasion,
    timepillarState: timepillarState,
    topMargin: topMargin,
    contentHeight: totalContentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: false,
    minHeight: timepillarState.timerMinHeight,
  );

  return BoardCardGenerator(
    top: cardPos.top,
    builder: (int col) => TimerTimepillardCard(
      timerOccasion: timerOccasion,
      ts: timepillarState,
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
    required TimepillarState timepillarState,
    required double topMargin,
    required double contentHeight,
    required double maxEndPos,
    required double minHeight,
    required bool hasSideDots,
  }) {
    final interval = timepillarState.timepillarInterval;
    final minuteStartPosition =
        eventOccasion.start.roundToMinute(minutesPerDot, roundingMinute);
    final minuteEndPosition =
        eventOccasion.end.roundToMinute(minutesPerDot, roundingMinute);
    final startsBeforeInterval =
        minuteStartPosition.isBefore(interval.startTime);
    final endsAfterInterval = minuteEndPosition.isAfter(interval.endTime);
    final startTime =
        startsBeforeInterval ? interval.startTime : eventOccasion.start;
    final topOffset = startsBeforeInterval
        ? 0.0
        : timeToPixels(minuteStartPosition.hour, minuteStartPosition.minute,
                timepillarState.dotDistance) -
            timepillarState.topOffset(startTime);

    final endTime = endsAfterInterval ? interval.endTime : eventOccasion.end;
    final dots = hasSideDots
        ? endTime.difference(startTime).inDots(minutesPerDot, roundingMinute)
        : 0;
    final dotHeight = dots * timepillarState.dotDistance;
    final renderedHeight = max(contentHeight, minHeight);
    var height = max(dotHeight, renderedHeight);
    if (topOffset + height > maxEndPos) {
      height = maxEndPos - topOffset;
    }
    final top = topOffset + topMargin + timepillarState.topPadding;
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
