import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/activity/timeformat.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final double margin;
  static const double cardHeight = 56.0,
      cardPadding = 4.0,
      cardMargin = 4.0,
      imageSize = 48.0;
  static const Duration duration = Duration(seconds: 1);

  const ActivityCard({Key key, this.activityOccasion, this.margin = 0.0})
      : assert(activityOccasion != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = abiliaTheme.textTheme;
    final occasion = activityOccasion.occasion;
    final activity = activityOccasion.activity;
    final timeFormat = hourAndMinuteFormat(context);
    final hasImage = activity.hasImage;
    final hasTitle = activity.title?.isNotEmpty == true;
    final signedOff = activity.isSignedOff(activityOccasion.day);
    final current = occasion == Occasion.current;
    final inactive = occasion == Occasion.past || signedOff;
    final themeData = inactive
        ? abiliaTheme.copyWith(
            textTheme: textTheme.copyWith(
              subhead:
                  textTheme.subhead.copyWith(color: AbiliaColors.white[140]),
              body2: textTheme.body2.copyWith(color: AbiliaColors.white[140]),
            ),
            iconTheme:
                abiliaTheme.iconTheme.copyWith(color: AbiliaColors.white[140]))
        : abiliaTheme;
    return AnimatedTheme(
      duration: duration,
      data: themeData,
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.symmetric(vertical: margin),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (innerContext) =>
                      ActivityPage(occasion: activityOccasion),
                ),
              );
            },
            child: AnimatedContainer(
              duration: duration,
              height: cardHeight,
              decoration: getBoxDecoration(current, inactive),
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (hasImage || signedOff)
                          CheckedImage.fromActivityOccasion(
                            activityOccasion: activityOccasion,
                            size: imageSize,
                            fit: BoxFit.cover,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: cardPadding),
                            child: Stack(children: <Widget>[
                              if (hasTitle)
                                Text(
                                  activity.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subhead,
                                ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  activity.fullDay
                                      ? Translator.of(context).translate.fullDay
                                      : activity.hasEndTime
                                          ? '${timeFormat(activity.startTime)} - ${timeFormat(activity.end)}'
                                          : '${timeFormat(activity.startTime)}',
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: buildInfoIcons(activity),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoIcons(Activity activity) => Row(
          children: [
        if (activity.checkable) AbiliaIcons.handi_check,
        if (!activity.fullDay) activity.alarm.iconData(),
        if (!activity.fullDay && activity.reminderBefore.isNotEmpty)
          AbiliaIcons.handi_reminder,
        if (activity.infoItem != null) AbiliaIcons.handi_info,
      ]
              .map(
                (icon) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(icon, size: 18),
                ),
              )
              .toList());
}
