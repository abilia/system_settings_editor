import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final double height;

  const ActivityCard({Key key, this.activityOccasion, this.height = 56.0})
      : assert(activityOccasion != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final occasion = activityOccasion.occasion;
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    final start = activity.start;
    final end = activity.end;
    final hasImage = activity.fileId != null;
    return Theme(
      data: pickTheme(context: context, occasion: occasion),
      child: Builder(
        builder: (context) => buildCard(
            hasImage, occasion, activity, context, timeFormat, start, end),
      ),
    );
  }

  Card buildCard(
      bool hasImage,
      Occasion occasion,
      Activity activity,
      BuildContext context,
      DateFormat timeFormat,
      DateTime start,
      DateTime end) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
        child: Row(
          children: <Widget>[
            hasImage
                ? Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: AnimatedOpacity(
                      opacity: occasion == Occasion.past ? .5 : 1,
                      child: FadeInCalenderImage(
                        imageFileId: activity.fileId,
                        width: 48,
                        height: 48,
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  )
                : SizedBox(
                    height: 56,
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      activity.title,
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: AbiliaColors.black, height: 1.2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            activity.fullDay
                                ? Translator.of(context).translate.fullDay
                                : activity.hasEndTime
                                    ? '${timeFormat.format(start)} - ${timeFormat.format(end)}'
                                    : '${timeFormat.format(start)}',
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(height: 1.3)),
                        Row(
                          children: <Widget>[
                            if (!activity.fullDay)
                              Icon(
                                iconDataFor(activity.alarm),
                                size: 16,
                              ),
                            if (!activity.fullDay &&
                                activity.reminderBefore.isNotEmpty)
                              Icon(
                                AbiliaIcons.handi_reminder,
                                size: 18,
                              ),
                            if (activity.infoItem != null)
                              Icon(
                                AbiliaIcons.handi_info,
                                size: 18,
                              ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData iconDataFor(AlarmType alarm) {
    if (alarm.sound) return AbiliaIcons.handi_alarm_vibration;
    if (alarm.vibrate) return AbiliaIcons.handi_vibration;
    return AbiliaIcons.handi_no_alarm_vibration;
  }

  ThemeData pickTheme({BuildContext context, Occasion occasion}) {
    final theme = Theme.of(context);
    switch (occasion) {
      case Occasion.past:
        return theme.copyWith(
            cardColor: AbiliaColors.transparantWhite[50],
            textTheme: theme.textTheme.copyWith(
                subhead: theme.textTheme.subtitle.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AbiliaColors.black[75]),
                body2: theme.textTheme.body1
                    .copyWith(decoration: TextDecoration.lineThrough)));
      case Occasion.current:
        return theme.copyWith(
            cardTheme: theme.cardTheme.copyWith(shape: redOutlineInputBorder));
      case Occasion.future:
      default:
        return theme;
    }
  }
}
