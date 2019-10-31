import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;

  const ActivityTile({Key key, this.activity})
      : assert(activity != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    final start = activity.startDate;
    final end = activity.endDate;
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) {
        final isCurrent = end.isAfter(now) && start.isBefore(now);
        final isPassed = end.isBefore(now);
        final hasImage = activity.fileId != null;
        return Theme(
          data: pickTheme(
              context: context, isPassed: isPassed, isCurrent: isCurrent),
          child: Builder(
            builder: (context) => Stack(children: <Widget>[
              Card(
                child: ListTile(
                  leading: hasImage
                      ? Opacity(
                          opacity: isPassed ? .5 : 1,
                          child: FadeInThumb(imageFileId: activity.fileId),
                        )
                      : null,
                  title: Text(activity.title,
                      style: Theme.of(context).textTheme.subtitle),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          '${timeFormat.format(start)} - ${timeFormat.format(end)}',
                          style: Theme.of(context).textTheme.body1),
                      Row(
                        children: <Widget>[
                          if (activity.alarm.type != Alarm.NoAlarm)
                            Icon(Icons.notifications_none),
                          if (activity.reminderBefore.isNotEmpty)
                            Icon(Icons.gesture),
                          if (activity.infoItem != null)
                            Icon(Icons.info_outline),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              if (isCurrent) NowBanner(),
            ]),
          ),
        );
      },
    );
  }

  ThemeData pickTheme({BuildContext context, bool isPassed, bool isCurrent}) {
    final theme = Theme.of(context);
    return isPassed
        ? theme.copyWith(
            cardColor: AbiliaColors.transparantWhite,
            textTheme: theme.textTheme.copyWith(
                subtitle: theme.textTheme.subtitle.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AbiliaColors.black[75]),
                body1: theme.textTheme.body1
                    .copyWith(decoration: TextDecoration.lineThrough)),
          )
        : isCurrent
            ? theme.copyWith(
                cardTheme:
                    theme.cardTheme.copyWith(shape: redOutlineInputBorder))
            : theme;
  }
}
