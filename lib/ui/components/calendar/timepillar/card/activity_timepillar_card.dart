import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityTimepillarCard extends TimepillarCard {
  final ActivityOccasion activityOccasion;
  final double textHeight;
  final DayParts dayParts;
  final TimepillarSide timepillarSide;
  final TimepillarMeasures measures;

  const ActivityTimepillarCard({
    Key? key,
    required this.activityOccasion,
    required CardPosition cardPosition,
    required int column,
    required this.textHeight,
    required this.dayParts,
    required this.timepillarSide,
    required this.measures,
  }) : super(column, cardPosition, key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        signedOff = activityOccasion.isSignedOff,
        current = activityOccasion.occasion == Occasion.current,
        past = activityOccasion.isPast,
        inactive = past || signedOff;

    final endTime = activityOccasion.end;
    final startTime = activityOccasion.start;
    final dotHeight = cardPosition.dots * measures.dotDistance;

    final right = TimepillarSide.right == timepillarSide;
    final timepillarInterval = measures.timepillarInterval;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.dotsInTimepillar != current.dotsInTimepillar ||
          previous.showCategoryColor != current.showCategoryColor,
      builder: (context, settings) {
        final decoration = getCategoryBoxDecoration(
          current: current,
          inactive: inactive,
          showCategoryColor: settings.showCategoryColor,
          category: activity.category,
          zoom: measures.zoom,
        );
        return Positioned(
          right: right ? null : column * measures.cardTotalWidth,
          left: right ? column * measures.cardTotalWidth : null,
          top: cardPosition.top,
          child: Tts.fromSemantics(
            activity.semanticsProperties(context),
            child: Stack(
              textDirection: right ? TextDirection.ltr : TextDirection.rtl,
              children: <Widget>[
                if (settings.dotsInTimepillar)
                  SideDots(
                    startTime: startTime.isBefore(timepillarInterval.startTime)
                        ? timepillarInterval.startTime
                        : startTime,
                    endTime: endTime.isAfter(timepillarInterval.endTime)
                        ? timepillarInterval.endTime
                        : endTime,
                    dots: cardPosition.dots,
                    dayParts: dayParts,
                  )
                else
                  SideTime(
                    occasion: activityOccasion.occasion,
                    height: dotHeight +
                        (dotHeight > 0
                            ? (decoration.border?.dimensions.vertical ?? 0)
                            : 0),
                    width: measures.cardWidth,
                    category: activity.category,
                    showCategoryColor: settings.showCategoryColor,
                  ),
                GestureDetector(
                  onTap: () {
                    final authProviders = copiedAuthProviders(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: authProviders,
                          child: ActivityPage(activityDay: activityOccasion),
                        ),
                        settings: RouteSettings(
                          name: 'ActivityPage $activityOccasion',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: right
                        ? EdgeInsets.only(
                            left: measures.dotSize + measures.hourPadding)
                        : EdgeInsets.only(
                            right: measures.dotSize + measures.hourPadding),
                    width: measures.cardWidth,
                    decoration: decoration,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: measures.activityCardMinHeight,
                        maxHeight: cardPosition.height,
                      ),
                      child: Padding(
                        padding: measures.cardPadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            if (hasTitle)
                              SizedBox(
                                height: textHeight,
                                child: Text(activity.title),
                              ),
                            if (hasImage || signedOff || past)
                              Padding(
                                padding: EdgeInsets.only(
                                    top: measures.cardPadding.top),
                                child: SizedBox(
                                  height: cardPosition.height -
                                      textHeight -
                                      measures.cardPadding.vertical -
                                      measures.cardPadding.top,
                                  child: EventImage.fromEventOccasion(
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
                ),
              ],
            ),
          ),
        );
      },
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
    Key? key,
    required this.occasion,
    required this.height,
    required this.width,
    required this.category,
    required this.showCategoryColor,
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
            Radius.circular(layout.timePillar.flarpRadius),
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
          inactive: occasion == Occasion.past,
          showCategoryColor: showCategoryColor,
        );
    }
  }
}
