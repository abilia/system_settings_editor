import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/settings_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityTimepillarCard extends StatelessWidget {
  static const double imageSize = 56.0,
      imagePadding = 16.0,
      imageHeigth = imageSize + imagePadding,
      crossWidth = 48.0,
      crossVerticalPadding = 36.0,
      width = 72.0,
      padding = 12.0,
      minHeight = 84.0,
      totalWith = dotSize + width + padding;
  static const int maxTitleLines = 5;

  final ActivityOccasion activityOccasion;
  final TextStyle textStyle;
  final int dots, column;
  final double top, endPos, height;
  final DateTime currentDay;

  const ActivityTimepillarCard({
    Key key,
    @required this.activityOccasion,
    @required this.dots,
    @required this.top,
    @required this.column,
    @required this.height,
    @required this.textStyle,
    @required this.currentDay,
  })  : assert(activityOccasion != null),
        endPos = top + height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final right = activity.category == Category.right,
        hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        signedOff = activityOccasion.isSignedOff,
        current = activityOccasion.occasion == Occasion.current,
        past = activityOccasion.occasion == Occasion.past,
        inactive = past || signedOff;

    final endTime = activityOccasion.end;
    final startTime = activityOccasion.start;
    final dotHeight = dots * dotDistance;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final decoration = getBoxDecoration(current, inactive);
        return Positioned(
          right: right ? null : column * totalWith,
          left: right ? column * totalWith : null,
          top: top,
          child: Tts.fromSemantics(
            SemanticsProperties(
              button: true,
              image: hasImage,
              label: hasTitle
                  ? activity.title
                  : hourAndMinuteFormat(context)(activityOccasion.start),
            ),
            child: Stack(
              textDirection: right ? TextDirection.ltr : TextDirection.rtl,
              children: <Widget>[
                if (settings.dotsInTimepillar)
                  SideDots(
                    startTime:
                        startTime.isBefore(currentDay) ? currentDay : startTime,
                    endTime: endTime.isAfter(currentDay.nextDay())
                        ? currentDay.nextDay()
                        : endTime,
                    dots: dots,
                  )
                else
                  SideTime(
                    occasion: activityOccasion.occasion,
                    category: activityOccasion.activity.category,
                    height: dotHeight +
                        (dotHeight > 0
                            ? decoration.border.dimensions.vertical
                            : 0),
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (innerContext) =>
                              ActivityPage(occasion: activityOccasion),
                          settings: RouteSettings(
                              name: 'ActivityPage $activityOccasion')),
                    );
                  },
                  child: Container(
                    margin: right
                        ? const EdgeInsets.only(left: dotSize + hourPadding)
                        : const EdgeInsets.only(right: dotSize + hourPadding),
                    decoration: decoration,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width,
                        minWidth: width,
                        minHeight: minHeight,
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
                                size: imageSize,
                              )
                            else if (past)
                              SizedBox(
                                width: crossWidth,
                                height: height - crossVerticalPadding,
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
  const SideTime({
    Key key,
    @required this.occasion,
    @required this.category,
    @required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ActivityTimepillarCard.width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: colorFromOccasion(occasion),
            borderRadius: const BorderRadius.all(Radius.circular(8.0))),
      ),
    );
  }

  Color colorFromOccasion(Occasion occasion) {
    switch (occasion) {
      case Occasion.current:
        return AbiliaColors.red;
      case Occasion.past:
        return AbiliaColors.transparentBlack20;
      default:
        return AbiliaColors.black;
    }
  }
}
