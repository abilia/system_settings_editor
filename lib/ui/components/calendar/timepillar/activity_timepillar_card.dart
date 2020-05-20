import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/settings_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class ActivityTimepillarCard extends StatelessWidget {
  static const double imageSize = 56.0,
      width = 72.0,
      padding = 12.0,
      minHeight = 84.0,
      totalWith = dotSize + width + padding;

  final ActivityOccasion activityOccasion;
  final TextStyle textStyle;
  final int dots, column;
  final double top, endPos, height;

  const ActivityTimepillarCard({
    Key key,
    @required this.activityOccasion,
    @required this.dots,
    @required this.top,
    @required this.column,
    @required this.height,
    @required this.textStyle,
  })  : assert(activityOccasion != null),
        endPos = top + height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final right = activity.category == Category.right,
        hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        signedOff = activity.isSignedOff(activityOccasion.day),
        current = activityOccasion.occasion == Occasion.current,
        inactive = activityOccasion.occasion == Occasion.past || signedOff;

    final endTime = activity.endClock(activityOccasion.day);
    final startTime = activity.startClock(activityOccasion.day);
    final dots = activityOccasion.activity.duration
        .inDots(minutesPerDot, roundingMinute);
    final dotHeight = dots * dotDistance;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final decoration = settings.dotsInTimepillar || endTime == startTime
            ? getBoxDecoration(current, inactive)
            : getBoxDecoration(current, inactive).copyWith(
                borderRadius:
                    activityOccasion.activity.category == Category.right
                        ? onlyRight
                        : onlyLeft,
              );
        return Positioned(
          right: right ? null : column * totalWith,
          left: right ? column * totalWith : null,
          top: top,
          child: Row(
            textDirection: right ? TextDirection.ltr : TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (settings.dotsInTimepillar)
                SideDots(
                  startTime: startTime,
                  endTime: endTime,
                  dots: dots,
                ),
              if (!settings.dotsInTimepillar)
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
                    ),
                  );
                },
                child: Container(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (hasTitle)
                            Text(
                              activity.title,
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.center,
                              style: textStyle.copyWith(
                                  color: inactive
                                      ? AbiliaColors.white140
                                      : AbiliaColors.black),
                            ),
                          if (hasImage || signedOff)
                            CheckedImage.fromActivityOccasion(
                              activityOccasion: activityOccasion,
                              size: imageSize,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
      width: dotSize,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: colorFromOccastion(occasion),
            borderRadius: category == Category.left ? onlyRight : onlyLeft),
      ),
    );
  }

  Color colorFromOccastion(Occasion occasion) {
    switch (occasion) {
      case Occasion.current:
        return AbiliaColors.red;
      case Occasion.past:
        return AbiliaColors.white120;
      case Occasion.future:
        return AbiliaColors.green;
      default:
        return AbiliaColors.green;
    }
  }
}
