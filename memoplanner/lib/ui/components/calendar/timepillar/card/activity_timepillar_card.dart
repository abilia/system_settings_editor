import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityTimepillarCard extends TimepillarCard {
  final ActivityOccasion activityOccasion;
  final TimepillarSide timepillarSide;
  final BoxDecoration decoration;

  final TimepillarBoardDataArguments args;
  TimepillarMeasures get measures => args.measures;

  const ActivityTimepillarCard({
    required this.activityOccasion,
    required CardPosition cardPosition,
    required int column,
    required this.timepillarSide,
    required this.decoration,
    required this.args,
    Key? key,
  }) : super(column, cardPosition, key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        hasContent = activityOccasion.hasTimepillarContent;
    final endTime = activityOccasion.end;
    final startTime = activityOccasion.start;
    final dotHeight = cardPosition.dots * measures.dotDistance;
    final right = TimepillarSide.right == timepillarSide;
    final timepillarInterval = measures.interval;
    final dotsInTimepillar = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.viewOptions.dots);
    final showCategoryColor = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.calendar.categories.showColors);
    final borderWidth = (decoration.padding?.vertical ?? 0) / 2;
    final imagePadding = measures.imagePadding.vertical / 2;
    final smallImagePadding = measures.smallImagePadding.vertical / 2;
    final textPadding = measures.textPadding.vertical / 2;

    final imageSize =
        hasImage ? measures.cardImageSize : measures.smallCardImageSize;
    final crossPadding =
        hasImage ? measures.crossPadding : measures.smallCrossPadding;
    final checkPadding =
        hasImage ? measures.checkPadding : measures.smallCrossPadding;
    final contentPadding = hasImage ? imagePadding : smallImagePadding;
    final checkMark = CheckMark(
      size: hasImage ? CheckMarkSize.small : CheckMarkSize.mini,
      fit: BoxFit.scaleDown,
    );
    final offsetIsMax =
        cardPosition.contentOffset + cardPosition.contentHeight >
            cardPosition.height;

    return Positioned(
      right: right ? null : column * measures.cardTotalWidth,
      left: right ? column * measures.cardTotalWidth : null,
      top: cardPosition.top,
      child: Tts.fromSemantics(
        activityOccasion.semanticsProperties(context),
        child: Stack(
          textDirection: right ? TextDirection.ltr : TextDirection.rtl,
          children: <Widget>[
            if (dotsInTimepillar)
              SideDots(
                startTime: startTime.isBefore(timepillarInterval.start)
                    ? timepillarInterval.start
                    : startTime,
                endTime: endTime.isAfter(timepillarInterval.end)
                    ? timepillarInterval.end
                    : endTime,
                dots: cardPosition.dots,
                dayParts: args.dayParts,
              )
            else
              SideTime(
                occasion: activityOccasion.occasion,
                height: dotHeight,
                width: measures.cardWidth,
                category: activity.category,
                showCategoryColor: showCategoryColor,
                nightMode: args.nightMode,
              ),
            GestureDetector(
              onTap: () {
                final authProviders = copiedAuthProviders(context);
                Navigator.push(
                  context,
                  ActivityPage.route(
                    activityDay: activityOccasion,
                    authProviders: authProviders,
                  ),
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: cardPosition.height,
                ),
                margin: right
                    ? EdgeInsets.only(
                        left: measures.dotSize + measures.hourIntervalPadding,
                      )
                    : EdgeInsets.only(
                        right: measures.dotSize + measures.hourIntervalPadding,
                      ),
                width: measures.cardWidth,
                decoration: decoration,
                child: Column(
                  mainAxisAlignment: activityOccasion.isPast ||
                          (activityOccasion.isCurrent && offsetIsMax)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    if (activityOccasion.isCurrent && !offsetIsMax)
                      SizedBox(height: cardPosition.contentOffset),
                    if (hasTitle) ...[
                      SizedBox(height: textPadding - borderWidth),
                      SizedBox(
                        width: measures.cardTextWidth,
                        child: Text(
                          activity.title,
                          maxLines: cardPosition.titleLines,
                        ),
                      ),
                      if (!hasContent)
                        SizedBox(height: textPadding - borderWidth),
                    ],
                    if (hasContent) ...[
                      SizedBox(
                        height: contentPadding - (!hasTitle ? borderWidth : 0),
                      ),
                      SizedBox(
                        height: imageSize,
                        width: imageSize,
                        child: EventImage(
                          event: activityOccasion,
                          crossPadding: crossPadding,
                          checkPadding: checkPadding,
                          checkMark: checkMark,
                          radius: layout.timepillar.card.imageCornerRadius,
                          nightMode: args.nightMode,
                        ),
                      ),
                      SizedBox(height: contentPadding - borderWidth),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SideTime extends StatelessWidget {
  final Occasion occasion;
  final double height;
  final double width;
  final int category;
  final bool showCategoryColor;
  final bool nightMode;

  const SideTime({
    required this.occasion,
    required this.height,
    required this.width,
    required this.category,
    required this.showCategoryColor,
    required this.nightMode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: categoryColor(
            category: category,
            inactive: occasion.isPast,
            showCategoryColor: showCategoryColor,
            nightMode: nightMode,
            current: occasion.isCurrent,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(layout.timepillar.flarpRadius),
          ),
        ),
      ),
    );
  }
}
