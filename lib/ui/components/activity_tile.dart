import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models/activity.dart';
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
    return BlocBuilder<ClockBloc, DateTime>(builder: (context, now) {
      final isCurrent = end.isAfter(now) && start.isBefore(now);

      return Theme(
        data: pickTheme(
            context: context,
            isPassed: end.isBefore(now),
            isCurrent: isCurrent),
        child: Builder(
          builder: (context) => Card(
            child: Stack(
              children: <Widget>[
                ListTile(
                  leading: activity.fileId != null
                      ? FadeInThumb(
                          imageFileId: activity.fileId,
                        )
                      : null,
                  title: Text(activity.title,
                      style: Theme.of(context).textTheme.title),
                  subtitle: Row(
                    children: <Widget>[
                      Text(
                          '${timeFormat.format(start)} - ${timeFormat.format(end)}',
                          style: Theme.of(context).textTheme.body1),
                    ],
                  ),
                ),
                if (isCurrent) NowBanner(),
              ],
            ),
          ),
        ),
      );
    });
  }

  ThemeData pickTheme({BuildContext context, bool isPassed, bool isCurrent}) {
    return isPassed
        ? Theme.of(context).copyWith(
            cardColor: AbiliaColors.transparantWhite,
            textTheme: Theme.of(context).textTheme.copyWith(
                title: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(decoration: TextDecoration.lineThrough),
                body1: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(decoration: TextDecoration.lineThrough)),
          )
        : isCurrent
            ? Theme.of(context).copyWith(
                cardTheme: CardTheme.of(context)
                    .copyWith(shape: redOutlineInputBorder))
            : Theme.of(context);
  }
}
