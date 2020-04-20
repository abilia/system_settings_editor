import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityTimepillarCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  static const double cardPadding = 4.0;
  static const double imageSize = 48.0;

  const ActivityTimepillarCard({Key key, this.activityOccasion})
      : assert(activityOccasion != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occasion = activityOccasion.occasion;
    final activity = activityOccasion.activity;
    final hasImage = activity.hasImage;
    final hasTitle = activity.title?.isNotEmpty == true;
    final signedOff = activity.isSignedOff(activityOccasion.day);
    final current = occasion == Occasion.current;
    final inactive = occasion == Occasion.past || signedOff;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (innerContext) => editActivityMultiBlocProvider(
              context,
              child: ActivityPage(occasion: activityOccasion),
            ),
          ),
        );
      },
      child: Container(
        decoration: _getBoxDecoration(current, inactive),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 72, minWidth: 72, minHeight: 84),
          child: Center(
            child: Column(
              children: <Widget>[
                if (hasTitle)
                  Text(
                    activity.title,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.caption.copyWith(
                        color: inactive
                            ? AbiliaColors.white[140]
                            : AbiliaColors.black),
                  ),
                if (hasImage || signedOff)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CheckMarkWrapper(
                          checked: signedOff,
                          child: hasImage
                              ? FadeInCalendarImage(
                                  imageFileId: activity.fileId,
                                  imageFilePath: activity.icon,
                                  activityId: activity.id,
                                  width: imageSize,
                                  height: imageSize,
                                )
                              : SizedBox(width: imageSize, height: imageSize),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(bool current, bool inactive) => inactive
      ? BoxDecoration(
          color: AbiliaColors.white[110],
          borderRadius: borderRadius,
          border: Border.all(
            color: AbiliaColors.white[120],
            width: 1.0,
          ),
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
              border: Border.all(
                color: AbiliaColors.white[120],
                width: 1.0,
              ),
            );
}
