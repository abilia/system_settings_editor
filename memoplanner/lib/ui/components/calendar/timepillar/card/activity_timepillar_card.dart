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

  const ActivityTimepillarCard({
    required this.activityOccasion,
    required CardPosition cardPosition,
    required int column,
    required this.dayParts,
    required this.timepillarSide,
    required this.measures,
    required this.decoration,
    Key? key,
  }) : super(column, cardPosition, key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        signedOff = activityOccasion.isSignedOff,
        past = activityOccasion.isPast;
    final endTime = activityOccasion.end;
    final startTime = activityOccasion.start;
    final dotHeight = cardPosition.dots * measures.dotDistance;
    final right = TimepillarSide.right == timepillarSide;
    final timepillarInterval = measures.interval;
    final dotsInTimepillar = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.viewOptions.dots);
    final showCategoryColor = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.calendar.categories.showColors);

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
                child: Padding(
                  padding: measures.cardPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (hasTitle) Text(activity.title),
                      if (hasImage || signedOff || past)
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: measures.cardPadding.top),
                            child: EventImage.fromEventOccasion(
                              fit: BoxFit.scaleDown,
                              eventOccasion: activityOccasion,
                              crossPadding: measures.cardPadding,
                              checkPadding: measures.cardPadding * 2,
                            ),
                          ),
                        )
                    ],
                  ),
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
