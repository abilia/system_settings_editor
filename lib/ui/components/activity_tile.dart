import 'package:flutter/material.dart';
import 'package:seagull/models/activity.dart';
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
    Widget getSubTitle(Activity activity) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(activity.startTime);
      final endTime = DateTime.fromMillisecondsSinceEpoch(
          activity.startTime + activity.duration);
      return Row(
        children: <Widget>[
          Text(
            '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
            style: Theme.of(context).textTheme.body1,
          ),
        ],
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: ListTile(
        leading: activity.fileId != null ? SizedBox( width:56, height: 56, child:Placeholder()) : null,
        title: Text(
          activity.title,
          style: Theme.of(context).textTheme.title,
        ),
        subtitle: getSubTitle(activity),
      ),
    );
  }
}
