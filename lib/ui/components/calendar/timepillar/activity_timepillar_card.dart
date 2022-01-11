import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityTimepillarCard extends StatelessWidget {
  static const int maxTitleLines = 5;

  final ActivityOccasion activityOccasion;
  final TextStyle textStyle;
  final int dots, column;
  final double top, endPos, height, textHeight;
  final TimepillarInterval timepillarInterval;
  final DayParts dayParts;
  final TimepillarSide timepillarSide;
  final TimepillarState timepillarState;

  const ActivityTimepillarCard({
    Key? key,
    required this.activityOccasion,
    required this.dots,
    required this.top,
    required this.column,
    required this.height,
    required this.textHeight,
    required this.textStyle,
    required this.timepillarInterval,
    required this.dayParts,
    required this.timepillarSide,
    required this.timepillarState,
  })  : endPos = top + height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final ts = timepillarState;
    final activity = activityOccasion.activity;
    final hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        signedOff = activityOccasion.isSignedOff,
        current = activityOccasion.occasion == Occasion.current,
        past = activityOccasion.occasion == Occasion.past,
        inactive = past || signedOff;

    final endTime = activityOccasion.end;
    final startTime = activityOccasion.start;
    final dotHeight = dots * ts.dotDistance;

    final right = TimepillarSide.right == timepillarSide;
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
        );
        return Positioned(
          right: right ? null : column * ts.totalWidth,
          left: right ? column * ts.totalWidth : null,
          top: top,
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
                    dots: dots,
                    dayParts: dayParts,
                  )
                else
                  SideTime(
                    occasion: activityOccasion.occasion,
                    height: dotHeight +
                        (dotHeight > 0
                            ? (decoration.border?.dimensions.vertical ?? 0)
                            : 0),
                    width: ts.width,
                    category: activity.category,
                    showCategoryColor: settings.showCategoryColor,
                  ),
                GestureDetector(
                  onTap: () {
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
                        ? EdgeInsets.only(left: ts.dotSize + ts.hourPadding)
                        : EdgeInsets.only(right: ts.dotSize + ts.hourPadding),
                    decoration: decoration,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ts.width,
                        minWidth: ts.width,
                        minHeight: ts.minHeight,
                        maxHeight: height,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(ts.cardPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            if (hasTitle)
                              SizedBox(
                                height: textHeight,
                                child: Text(
                                  activity.title,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.center,
                                  maxLines: maxTitleLines,
                                  style: textStyle,
                                ),
                              ),
                            if (hasImage || signedOff || past)
                              Padding(
                                padding: EdgeInsets.only(top: ts.cardPadding),
                                child: SizedBox(
                                  height:
                                      height - textHeight - ts.cardPadding * 3,
                                  child: ActivityImage.fromActivityOccasion(
                                    activityOccasion: activityOccasion,
                                    crossPadding:
                                        EdgeInsets.all(ts.cardPadding),
                                    checkPadding:
                                        EdgeInsets.all(ts.cardPadding * 2),
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
            borderRadius: BorderRadius.all(Radius.circular(8.0.s))),
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
