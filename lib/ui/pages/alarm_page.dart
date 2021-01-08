import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class FullScreenAlarm extends StatelessWidget {
  final NotificationAlarm alarm;

  const FullScreenAlarm({Key key, this.alarm}) : super(key: key);
  @override
  Widget build(BuildContext context) => (alarm is NewAlarm)
      ? AlarmPage(alarm: alarm)
      : ReminderPage(reminder: alarm);
}

class AlarmPage extends StatelessWidget {
  final NewAlarm alarm;
  final Widget previewImage;
  const AlarmPage({
    Key key,
    @required this.alarm,
    this.previewImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(title: Translator.of(context).translate.alarm),
      body: Padding(
        padding: const EdgeInsets.all(ActivityInfo.margin),
        child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, activitiesState) => ActivityInfo(
            alarm.activityDay.fromActivitiesState(activitiesState),
            previewImage: previewImage,
          ),
        ),
      ),
    );
  }
}

class NavigatableAlarmPage extends StatefulWidget {
  final NewAlarm alarm;
  final AlarmNavigator alarmNavigator;
  const NavigatableAlarmPage(
      {Key key, @required this.alarm, @required this.alarmNavigator});

  @override
  _NavigatableAlarmPageState createState() =>
      _NavigatableAlarmPageState(alarm, alarmNavigator);
}

class _NavigatableAlarmPageState
    extends AlarmAwareWidgetState<NavigatableAlarmPage> {
  _NavigatableAlarmPageState(
      NotificationAlarm alarm, AlarmNavigator alarmNavigator)
      : super(alarm, alarmNavigator);

  @override
  Widget build(BuildContext context) => AlarmPage(alarm: widget.alarm);
}

class ReminderPage extends StatelessWidget {
  final NewReminder reminder;
  final ActivityDay activityDay;
  const ReminderPage({Key key, @required this.reminder, this.activityDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = reminder.reminder
        .toReminderHeading(translate, reminder is ReminderBefore);
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.reminder,
        icon: AbiliaIcons.handi_reminder,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 30),
                child: Tts(
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: AbiliaColors.red),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
                builder: (context, activitiesState) => ActivityInfo(
                  reminder.activityDay.fromActivitiesState(activitiesState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigatableReminderPage extends StatefulWidget {
  final NewReminder reminder;
  final AlarmNavigator alarmNavigator;
  const NavigatableReminderPage(
      {Key key, @required this.reminder, @required this.alarmNavigator})
      : super(key: key);

  @override
  _NavigatableReminderPageState createState() =>
      _NavigatableReminderPageState(reminder, alarmNavigator);
}

class _NavigatableReminderPageState
    extends AlarmAwareWidgetState<NavigatableReminderPage> {
  _NavigatableReminderPageState(
      NotificationAlarm reminder, AlarmNavigator alarmNavigator)
      : super(reminder, alarmNavigator);

  @override
  Widget build(BuildContext context) => ReminderPage(reminder: widget.reminder);
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
