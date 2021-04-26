import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityTimepillarCard extends StatelessWidget {
  static const int maxTitleLines = 5;

  final ActivityOccasion activityOccasion;
  final TextStyle textStyle;
  final int dots, column;
  final double top, endPos, height;
  final TimepillarInterval timepillarInterval;
  final DayParts dayParts;
  final TimepillarSide timepillarSide;
  final TimepillarState timepillarState;

  const ActivityTimepillarCard({
    Key key,
    @required this.activityOccasion,
    @required this.dots,
    @required this.top,
    @required this.column,
    @required this.height,
    @required this.textStyle,
    @required this.timepillarInterval,
    @required this.dayParts,
    @required this.timepillarSide,
    @required this.timepillarState,
  })  : assert(activityOccasion != null),
        endPos = top + height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
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

    final right = TimepillarSide.RIGHT == timepillarSide;

    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.dotsInTimepillar != current.dotsInTimepillar,
      builder: (context, settings) {
        final decoration = getBoxDecoration(current, inactive);
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
                    category: activityOccasion.activity.category,
                    height: dotHeight +
                        (dotHeight > 0
                            ? decoration.border.dimensions.vertical
                            : 0),
                    width: ts.width,
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CopiedAuthProviders(
                                blocContext: context,
                                child: ActivityPage(occasion: activityOccasion),
                              ),
                          settings: RouteSettings(
                              name: 'ActivityPage $activityOccasion')),
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
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            if (hasTitle)
                              Text(
                                activity.title,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                maxLines: maxTitleLines,
                                style: textStyle,
                              ),
                            if (hasImage || signedOff)
                              ActivityImage.fromActivityOccasion(
                                activityOccasion: activityOccasion,
                                size: ts.imageSize,
                              )
                            else if (past)
                              SizedBox(
                                width: ts.crossWidth,
                                height: height - ts.crossVerticalPadding,
                                child: const CrossOver(),
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
  final int category;
  final double height;
  final double width;
  const SideTime({
    Key key,
    @required this.occasion,
    @required this.category,
    @required this.height,
    @required this.width,
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
      case Occasion.past:
        return AbiliaColors.white140;
      default:
        return AbiliaColors.black60;
    }
  }
}
