import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/colors.dart';

class AlarmPage extends StatefulWidget {
  final NewAlarm alarm;
  final AlarmNavigator alarmNavigator;
  const AlarmPage(
      {Key key, @required this.alarm, @required this.alarmNavigator});

  @override
  _AlarmPageState createState() => _AlarmPageState(alarm, alarmNavigator);
}

class _AlarmPageState extends AlarmAwareWidgetState<AlarmPage> {
  _AlarmPageState(NotificationAlarm alarm, AlarmNavigator alarmNavigator)
      : super(alarm, alarmNavigator);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(title: Translator.of(context).translate.alarm),
      body: Padding(
        padding: const EdgeInsets.all(ActivityInfo.margin),
        child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, activitiesState) => ActivityInfo(
              widget.alarm.activityDay.fromActivitiesState(activitiesState)),
        ),
      ),
    );
  }
}

class ReminderPage extends StatefulWidget {
  final NewReminder reminder;
  final AlarmNavigator alarmNavigator;
  const ReminderPage(
      {Key key, @required this.reminder, @required this.alarmNavigator})
      : super(key: key);

  @override
  _ReminderPageState createState() =>
      _ReminderPageState(reminder, alarmNavigator);
}

class _ReminderPageState extends AlarmAwareWidgetState<ReminderPage> {
  _ReminderPageState(NotificationAlarm reminder, AlarmNavigator alarmNavigator)
      : super(reminder, alarmNavigator);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = widget.reminder.reminder
        .toReminderHeading(translate, widget.reminder is ReminderBefore);
    return Scaffold(
      appBar: AbiliaAppBar(title: translate.reminders),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 30),
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: AbiliaColors.red),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
                builder: (context, activitiesState) => ActivityInfo(
                  widget.reminder.activityDay
                      .fromActivitiesState(activitiesState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class AlarmAwareWidgetState<T extends StatefulWidget> extends State<T>
    with RouteAware {
  final NotificationAlarm alarm;
  final AlarmNavigator alarmNavigator;

  AlarmAwareWidgetState(this.alarm, this.alarmNavigator);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    alarmNavigator.alarmRouteObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPop() {
    alarmNavigator.removedFromRoutes(alarm);
  }

  @override
  void dispose() {
    alarmNavigator.alarmRouteObserver.unsubscribe(this);
    super.dispose();
  }
}
