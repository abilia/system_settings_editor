import 'dart:async';

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
    if (alarm.fullScreenActivity) {
      return FullScreenActivityPage(activityDay: alarm.activityDay);
    }
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.alarm,
        iconData: AbiliaIcons.handiAlarmVibration,
        trailing: Padding(
          padding: layout.alarmPage.alarmClockPadding,
          child: AbiliaClock(
            style: Theme.of(context).textTheme.caption?.copyWith(
                  color: AbiliaColors.white,
                ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.s),
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
      bottomNavigationBar: AlarmBottomNavigationBar(alarm: alarm),
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
      bottomNavigationBar: AlarmBottomNavigationBar(alarm: reminder),
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

class AlarmBottomNavigationBar extends StatelessWidget with ActivityMixin {
  const AlarmBottomNavigationBar({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  final ActivityAlarm alarm;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final activityDay = alarm.activityDay;
    final displayCheckButton =
        activityDay.activity.checkable && !activityDay.isSignedOff;
    final closeButton = CloseButton(onPressed: () => popAlarm(context, alarm));
    return BottomAppBar(
      child: Padding(
        padding: layout.navigationBar.padding,
        child: Row(
          mainAxisAlignment: displayCheckButton
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (!displayCheckButton)
              closeButton
            else ...[
              Expanded(child: closeButton),
              SizedBox(width: layout.navigationBar.spaceBetweeen),
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
    );
  }
}

class TimerAlarmPage extends StatelessWidget with ActivityMixin {
  final TimerAlarm timerAlarm;

  const TimerAlarmPage({
    Key? key,
    required this.timerAlarm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final timer = timerAlarm.timer;
    return Theme(
      data: abiliaTheme.copyWith(scaffoldBackgroundColor: AbiliaColors.white),
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: translate.timeIsUp,
          iconData: AbiliaIcons.stopWatch,
        ),
        body: Padding(
          padding: layout.timerPage.bodyPadding,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: border,
              borderRadius: borderRadius,
            ),
            constraints: const BoxConstraints.expand(),
            child: Column(
              children: <Widget>[
                TimerTopInfo(timer: timerAlarm.timer),
                Divider(
                  height: layout.activityPage.dividerHeight,
                  endIndent: 0,
                  indent: layout.activityPage.dividerIndentation,
                ),
                Expanded(
                  child: Padding(
                    padding: layout.timerPage.mainContentPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FinishedTimerWheel(timer: timer),
                        ),
                        SizedBox(
                          height: layout.timerPage.pauseTextHeight,
                          child: timer.paused
                              ? Tts(
                                  child: Text(
                                    Translator.of(context)
                                        .translate
                                        .timerPaused,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        ?.copyWith(
                                          color: AbiliaColors.red,
                                        ),
                                  ),
                                )
                              : null,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: CloseButton(
            onPressed: () => popAlarm(context, timerAlarm),
          ),
        ),
      ),
    );
  }
}

class FinishedTimerWheel extends StatefulWidget {
  const FinishedTimerWheel({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  State<FinishedTimerWheel> createState() => _FinishedTimerWheelState();
}

class _FinishedTimerWheelState extends State<FinishedTimerWheel> {
  bool showFirst = true;
  Timer? _timer;
  final Duration blink = const Duration(milliseconds: 500);
  late Widget first;
  late Widget second;

  @override
  void initState() {
    first = TimerWheel.finished(
      withPaint: true,
      length: widget.timer.duration.inMinutes,
    );
    second = TimerWheel.finished(
      length: widget.timer.duration.inMinutes,
    );
    super.initState();
    _timer = Timer.periodic(blink, (timer) {
      setState(() {
        showFirst = !showFirst;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _FinishedTimerWheelState();

  @override
  Widget build(BuildContext context) {
    return showFirst ? first : second;
  }
}
