import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmPage extends StatelessWidget {
  final NewAlarm alarm;
  final Widget? previewImage;

  const AlarmPage({
    required this.alarm,
    this.previewImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.alarm,
        iconData: AbiliaIcons.alarmBell,
        trailing: AbiliaClock(
          style: Theme.of(context).textTheme.caption?.copyWith(
                color: AbiliaColors.white,
              ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(ActivityInfo.margin),
        child: BlocSelector<ActivitiesBloc, ActivitiesState, ActivityDay>(
          selector: (activitiesState) => ActivityDay(
            activitiesState
                .newActivityFromLoadedOrGiven(alarm.activityDay.activity),
            alarm.activityDay.day,
          ),
          builder: (context, ad) => ActivityInfo(
            ad,
            previewImage: previewImage,
            alarm: alarm,
          ),
        ),
      ),
      bottomNavigationBar: AlarmBottomAppBar(alarm: alarm),
    );
  }
}

class ReminderPage extends StatelessWidget {
  final NewReminder reminder;

  const ReminderPage({
    Key? key,
    required this.reminder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = reminder.reminder
        .toReminderHeading(translate, reminder is ReminderBefore);
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.reminder,
        iconData: AbiliaIcons.handiReminder,
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
                        ?.copyWith(color: AbiliaColors.red),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocSelector<ActivitiesBloc, ActivitiesState, ActivityDay>(
                selector: (activitiesState) => ActivityDay(
                  activitiesState.newActivityFromLoadedOrGiven(
                      reminder.activityDay.activity),
                  reminder.activityDay.day,
                ),
                builder: (context, ad) => ActivityInfo(ad, alarm: reminder),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AlarmBottomAppBar(alarm: reminder),
    );
  }
}

class PopAwareAlarmPage extends StatelessWidget {
  final Widget child;
  final AlarmNavigator alarmNavigator;
  final NotificationAlarm alarm;

  const PopAwareAlarmPage({
    required this.alarm,
    required this.alarmNavigator,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          AlarmNavigator.log.fine('onWillPop $alarm');
          alarmNavigator.removedFromRoutes(alarm);
          await notificationPlugin.cancel(alarm.hashCode);
          return true;
        },
        child: child,
      );
}

class AlarmBottomAppBar extends StatelessWidget with ActivityMixin {
  const AlarmBottomAppBar({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  final NotificationAlarm alarm;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final activityDay = alarm.activityDay;
    final displayCheckButton =
        activityDay.activity.checkable && !activityDay.isSignedOff;
    final closeButton = CloseButton(onPressed: () => popAlarm(context, alarm));
    return BottomAppBar(
      elevation: 0.0,
      child: Container(
        color: AbiliaColors.black80,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.s, 8.s, 12.s, 12.s),
          child: Row(
            mainAxisAlignment: displayCheckButton
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (!displayCheckButton)
                closeButton
              else ...[
                Expanded(child: closeButton),
                SizedBox(width: 8.s),
                Expanded(
                  child: GreenButton(
                    key: TestKey.activityCheckButton,
                    text: translate.check,
                    icon: AbiliaIcons.handiCheck,
                    onPressed: () async {
                      final checked =
                          await checkConfirmation(context, activityDay);
                      if (checked == true) {
                        await cancelNotifications(
                          uncheckedReminders(activityDay),
                        );
                        await popAlarm(context, alarm);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
