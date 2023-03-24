import 'dart:math';

import 'package:collection/collection.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/ui/all.dart';

class TimepillarBoardDataArguments {
  final TextStyle textStyle;
  final double textScaleFactor;
  final DayParts dayParts;
  final TimepillarMeasures measures;
  final double topMargin;
  final double bottomMargin;
  final bool showCategoryColor;
  final bool nightMode;

  const TimepillarBoardDataArguments({
    required this.textStyle,
    required this.textScaleFactor,
    required this.dayParts,
    required this.measures,
    required this.topMargin,
    required this.bottomMargin,
    required this.showCategoryColor,
    required this.nightMode,
  });
}

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
    required TimepillarBoardDataArguments args,
    required TimepillarSide timepillarSide,
  }) {
    final measures = args.measures;
    final maxCardHeight = measures.imagePadding.vertical +
        measures.cardImageSize +
        measures.textPadding.top +
        args.textStyle.fontSize! *
            args.textStyle.height! *
            TimepillarCard.defaultTitleLines;
    final maxEndPos = args.topMargin +
        measures.timePillarHeight +
        args.bottomMargin +
        measures.dotDistance +
        maxCardHeight;

    eventOccasions.sort();
    final scheduled = <List<TimepillarCard>>[];
    ActivityLoop:
    for (final eventOccasion in eventOccasions) {
      final card = eventOccasion is ActivityOccasion
          ? _activityCard(
              activityOccasion: eventOccasion,
              args: args,
              maxEndPos: maxEndPos,
              timepillarSide: timepillarSide,
            )
          : eventOccasion is TimerOccasion
              ? _timerCard(
                  timerOccasion: eventOccasion,
                  args: args,
                  maxEndPos: maxEndPos,
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
  required TimepillarBoardDataArguments args,
  required double maxEndPos,
  required TimepillarSide timepillarSide,
}) {
  final decoration = getCategoryBoxDecoration(
    current: activityOccasion.occasion.isCurrent,
    inactive: activityOccasion.isPast || activityOccasion.isSignedOff,
    showCategoryColor: args.showCategoryColor,
    nightMode: args.nightMode,
    category: activityOccasion.activity.category,
    zoom: args.measures.zoom,
    radius: args.measures.borderRadius,
  );
  final contentHeight = args.measures.getContentHeight(
    occasion: activityOccasion,
    decoration: decoration,
    textScaleFactor: args.textScaleFactor,
    textStyle: args.textStyle,
  );
  final cardPosition = CardPosition.calculate(
    eventOccasion: activityOccasion,
    measures: args.measures,
    topMargin: args.topMargin,
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
      timepillarSide: timepillarSide,
      args: args,
      decoration: decoration,
      titleLines: titleLines,
    ),
  );
}

BoardCardGenerator _timerCard({
  required TimerOccasion timerOccasion,
  required TimepillarBoardDataArguments args,
  required double maxEndPos,
}) {
  final decoration = getCategoryBoxDecoration(
    current: timerOccasion.isOngoing,
    inactive: timerOccasion.isPast,
    showCategoryColor: false,
    nightMode: args.nightMode,
    category: timerOccasion.category,
    zoom: args.measures.zoom,
    radius: args.measures.borderRadius,
  );
  final contentHeight = args.measures.getContentHeight(
    occasion: timerOccasion,
    decoration: decoration,
    textScaleFactor: args.textScaleFactor,
    textStyle: args.textStyle,
  );

  final cardPos = CardPosition.calculate(
    eventOccasion: timerOccasion,
    measures: args.measures,
    topMargin: args.topMargin,
    contentHeight: contentHeight,
    maxEndPos: maxEndPos,
    hasSideDots: false,
  );

  return BoardCardGenerator(
    top: cardPos.top,
    builder: (int col) => TimerTimepillarCard(
      timerOccasion: timerOccasion,
      measures: args.measures,
      column: col,
      cardPosition: cardPos,
      decoration: decoration,
      nightMode: args.nightMode,
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
