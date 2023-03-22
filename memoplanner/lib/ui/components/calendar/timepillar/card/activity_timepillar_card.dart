import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityTimepillarCard extends TimepillarCard {
  final ActivityOccasion activityOccasion;
  final DayParts dayParts;
  final TimepillarSide timepillarSide;
  final TimepillarMeasures measures;
  final BoxDecoration decoration;
  final int titleLines;

  const ActivityTimepillarCard({
    required this.activityOccasion,
    required CardPosition cardPosition,
    required int column,
    required this.dayParts,
    required this.timepillarSide,
    required this.measures,
    required this.decoration,
    required this.titleLines,
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
                dayParts: dayParts,
              )
            else
              SideTime(
                occasion: activityOccasion.occasion,
                height: dotHeight,
                width: measures.cardWidth,
                category: activity.category,
                showCategoryColor: showCategoryColor,
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
                  children: <Widget>[
                    if (hasTitle) ...[
                      SizedBox(height: textPadding - borderWidth),
                      SizedBox(
                        width: measures.cardTextWidth,
                        child: Text(activity.title, maxLines: titleLines),
                      ),
                      if (!hasContent)
                        SizedBox(height: textPadding - borderWidth),
                    ],
                    if (hasContent) ...[
                      SizedBox(
                          height:
                              contentPadding - (!hasTitle ? borderWidth : 0)),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: imageSize,
                            width: imageSize,
                            child: EventImage.fromEventOccasion(
                              eventOccasion: activityOccasion,
                              crossPadding: crossPadding,
                              checkPadding: checkPadding,
                              checkMark: checkMark,
                              radius: layout.timepillar.card.imageCornerRadius,
                            ),
                          ),
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

  const SideTime({
    required this.occasion,
    required this.height,
    required this.width,
    required this.category,
    required this.showCategoryColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorFromOccasion(occasion),
          borderRadius: BorderRadius.all(
            Radius.circular(layout.timepillar.flarpRadius),
          ),
        ),
      ),
    );
  }

  Color colorFromOccasion(Occasion occasion) {
    switch (occasion) {
      case Occasion.current:
        return AbiliaColors.red;
      default:
        return categoryColor(
          category: category,
          inactive: occasion.isPast,
          showCategoryColor: showCategoryColor,
        );
    }
  }
}
