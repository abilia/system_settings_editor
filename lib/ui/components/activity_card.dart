import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final double height;

  const ActivityCard({Key key, this.activityOccasion, this.height = 80.0})
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
        builder: (context) => Stack(children: <Widget>[
          Card(
            child: SizedBox(
              height: height,
              child: ListTile(
                leading: hasImage
                    ? AnimatedOpacity(
                        opacity: occasion == Occasion.past ? .5 : 1,
                        child: FadeInCalenderImage(
                          imageFileId: activity.fileId,
                          width: 56,
                          height: 56,
                        ),
                        duration: const Duration(seconds: 1),
                      )
                    : null,
                title: Text(activity.title,
                    softWrap: false,
                    style: Theme.of(context).textTheme.subtitle),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        activity.fullDay
                            ? Translator.of(context).translate.fullDay
                            : activity.hasEndTime
                                ? '${timeFormat.format(start)} - ${timeFormat.format(end)}'
                                : '${timeFormat.format(start)}',
                        style: Theme.of(context).textTheme.body1),
                    Row(
                      children: <Widget>[
                        if (activity.alarm.type != Alarm.NoAlarm)
                          Icon(AbiliaIcons.handi_alarm),
                        if (activity.reminderBefore.isNotEmpty)
                          Icon(AbiliaIcons.handi_reminder),
                        if (activity.infoItem != null)
                          Icon(AbiliaIcons.handi_info),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          NowBanner(visible: occasion == Occasion.current),
        ]),
      ),
    );
  }
}

ThemeData pickTheme({BuildContext context, Occasion occasion}) {
  final theme = Theme.of(context);
  switch (occasion) {
    case Occasion.past:
      return theme.copyWith(
          cardColor: AbiliaColors.transparantWhite[50],
          textTheme: theme.textTheme.copyWith(
              subtitle: theme.textTheme.subtitle.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AbiliaColors.black[75]),
              body1: theme.textTheme.body1
                  .copyWith(decoration: TextDecoration.lineThrough)));
    case Occasion.current:
      return theme.copyWith(
          cardTheme: theme.cardTheme.copyWith(shape: redOutlineInputBorder));
    case Occasion.future:
    default:
      return theme;
  }
}
