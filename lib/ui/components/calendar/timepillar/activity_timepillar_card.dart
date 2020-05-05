import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityTimepillarCard extends StatelessWidget {
  static const double imageSize = 56.0,
      width = 72.0,
      padding = 12.0,
      minHeight = 84.0,
      totalWith = dotSize + width + padding;

  final ActivityOccasion activityOccasion;
  final TextStyle textStyle;
  final int dots, column;
  final double top, endPos;

  const ActivityTimepillarCard({
    Key key,
    @required this.activityOccasion,
    @required this.dots,
    @required this.top,
    @required this.column,
    @required double height,
    @required this.textStyle,
  })  : assert(activityOccasion != null),
        endPos = top + height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final bool right = activity.category == Category.right,
        hasImage = activity.hasImage,
        hasTitle = activity.hasTitle,
        signedOff = activity.isSignedOff(activityOccasion.day),
        current = activityOccasion.occasion == Occasion.current,
        inactive = activityOccasion.occasion == Occasion.past || signedOff;

    return Positioned(
      right: right ? null : column * totalWith,
      left: right ? column * totalWith : null,
      top: top,
      child: Row(
        textDirection: right ? TextDirection.ltr : TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SideDots(
            startTime: activity.startClock(activityOccasion.day),
            endTime: activity.endClock(activityOccasion.day),
            dots: dots,
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
              decoration: _getBoxDecoration(current, inactive),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width,
                  minWidth: width,
                  minHeight: minHeight,
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
                                  ? AbiliaColors.white[140]
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
  }

  BoxDecoration _getBoxDecoration(bool current, bool inactive) => inactive
      ? BoxDecoration(
          color: AbiliaColors.white[110],
          borderRadius: borderRadius,
          border: border,
        )
      : current
          ? BoxDecoration(
              color: AbiliaColors.white,
              borderRadius: borderRadius,
              border: Border.all(
                color: AbiliaColors.red,
                width: 2.0,
              ),
            )
          : BoxDecoration(
              color: AbiliaColors.white,
              borderRadius: borderRadius,
              border: border,
            );
}
