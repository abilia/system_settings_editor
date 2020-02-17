import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class AlarmPage extends StatelessWidget {
  final Activity activity;
  final bool atStartTime, atEndTime;
  const AlarmPage(
      {Key key,
      @required this.activity,
      this.atStartTime = false,
      this.atEndTime = false})
      : super(key: TestKey.onScreenAlarm);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(title: Translator.of(context).translate.alarm),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
              child: AlarmActivityTimeRange(
                  activity: activity,
                  atStartTime: atStartTime,
                  atEndTime: atEndTime),
            ),
            Expanded(
              child: ActivityInfo(activity: activity),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmActivityTimeRange extends StatelessWidget {
  const AlarmActivityTimeRange({
    Key key,
    @required this.activity,
    @required this.atStartTime,
    @required this.atEndTime,
  }) : super(key: key);

  final Activity activity;
  final bool atStartTime;
  final bool atEndTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TimeText(
          date: activity.start,
          active: atStartTime,
        ),
        if (activity.hasEndTime)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('-', style: Theme.of(context).textTheme.headline),
          ),
        if (activity.hasEndTime)
          TimeText(
            date: activity.end,
            active: atEndTime,
          ),
      ],
    );
  }
}

class TimeText extends StatelessWidget {
  const TimeText({
    Key key,
    @required this.date,
    this.active = false,
  }) : super(key: key);
  final DateTime date;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    return Container(
      constraints: BoxConstraints(minWidth: 92.0, minHeight: 52.0),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AbiliaColors.red,
            width: 2.0,
            style: active ? BorderStyle.solid : BorderStyle.none),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Center(
          child: Text(
            timeFormat.format(date),
            style: Theme.of(context).textTheme.headline,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
