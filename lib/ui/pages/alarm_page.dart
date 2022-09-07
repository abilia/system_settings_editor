import 'dart:async';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
      return FullScreenActivityPage(alarm: alarm);
    }
    return Theme(
      data: abiliaWhiteTheme,
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: Translator.of(context).translate.alarm,
          iconData: AbiliaIcons.handiAlarmVibration,
          height: layout.appBar.mediumHeight,
          trailing: Padding(
            padding: layout.alarmPage.clockPadding,
            child: AbiliaClock(
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: AbiliaColors.white,
                  ),
            ),
          ),
        ),
        body: Padding(
          padding: layout.templates.s1,
          child: BlocProvider<ActivityCubit>(
            create: (context) => ActivityCubit(
              activityDay: alarm.activityDay,
              activitiesBloc: context.read<ActivitiesBloc>(),
            ),
            child: BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) => ActivityInfo(
                state.activityDay,
                previewImage: previewImage,
                alarm: alarm,
              ),
            ),
          ),
        ),
        bottomNavigationBar: AlarmBottomNavigationBar(alarm: alarm),
      ),
    );
  }
}

class ReminderPage extends StatelessWidget {
  final NewReminder reminder;

  const ReminderPage({
    required this.reminder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = reminder.reminder
        .toReminderHeading(translate, reminder is ReminderBefore);
    return Theme(
      data: abiliaWhiteTheme,
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: translate.reminder,
          iconData: AbiliaIcons.handiReminder,
          height: layout.appBar.mediumHeight,
          trailing: Padding(
            padding: layout.alarmPage.clockPadding,
            child: AbiliaClock(
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: AbiliaColors.white,
                  ),
            ),
          ),
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
                child: BlocProvider<ActivityCubit>(
                  create: (context) => ActivityCubit(
                    activityDay: reminder.activityDay,
                    activitiesBloc: context.read<ActivitiesBloc>(),
                  ),
                  child: BlocBuilder<ActivityCubit, ActivityState>(
                    builder: (context, state) =>
                        ActivityInfo(state.activityDay, alarm: reminder),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AlarmBottomNavigationBar(alarm: reminder),
      ),
    );
  }
}

class PopAwareAlarmPage extends StatefulWidget {
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
  State<PopAwareAlarmPage> createState() => _PopAwareAlarmPageState();
}

class _PopAwareAlarmPageState extends State<PopAwareAlarmPage> {
  bool isCanceled = false;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          AlarmNavigator.log.fine('onWillPop ${widget.alarm}');
          widget.alarmNavigator.removedFromRoutes(widget.alarm);
          if (!isCanceled) {
            await notificationPlugin.cancel(widget.alarm.hashCode);
          }
          return true;
        },
        child: BlocListener<TouchDetectionCubit, Touch>(
          listenWhen: (previous, current) => !isCanceled,
          listener: (context, state) async {
            isCanceled = true;
            await notificationPlugin.cancel(widget.alarm.hashCode);
          },
          child: widget.child,
        ),
      );
}

class AlarmBottomNavigationBar extends StatelessWidget with ActivityMixin {
  const AlarmBottomNavigationBar({
    required this.alarm,
    Key? key,
  }) : super(key: key);

  final ActivityAlarm alarm;

  bool get displayCheckButton {
    final activityDay = alarm.activityDay;
    final activity = activityDay.activity;
    if (activity.checkable && !activityDay.isSignedOff) {
      if (alarm is ReminderUnchecked) return true;
      if (alarm is ReminderBefore) return false;
      if (alarm is EndAlarm) return true;
      if (alarm is StartAlarm) {
        if (activity.alarm.onlyStart) return true;
        if (activity.hasEndTime) return false;
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final closeButton = CloseButton(
      onPressed: () => popAlarm(
        activityRepository: context.read<LicenseCubit>().validLicense ? context.read<ActivityRepository>() : null,
        navigator: Navigator.of(context),
        alarm: alarm,
      ),
    );
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
                  text: Translator.of(context).translate.check,
                  icon: AbiliaIcons.handiCheck,
                  onPressed: () => checkConfirmationAndRemoveAlarm(
                    context,
                    alarm.activityDay,
                    alarm: alarm,
                  ),
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
    required this.timerAlarm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final timer = timerAlarm.timer;
    return Theme(
      data: abiliaWhiteTheme,
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: translate.timeIsUp,
          iconData: AbiliaIcons.stopWatch,
        ),
        body: Padding(
          padding: layout.templates.s1,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: border,
              borderRadius: borderRadius,
            ),
            constraints: const BoxConstraints.expand(),
            child: Column(
              children: <Widget>[
                if (timer.hasTitle || timer.hasImage) ...[
                  TimerTopInfo(timer: timer),
                  Divider(
                    height: layout.activityPage.dividerHeight,
                    endIndent: 0,
                    indent: layout.activityPage.dividerIndentation,
                  ),
                ],
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
            onPressed: () => popAlarm(
              navigator: Navigator.of(context),
              alarm: timerAlarm,
              validLicense: context.read<LicenseCubit>().validLicense,
            ),
          ),
        ),
      ),
    );
  }
}

class FinishedTimerWheel extends StatefulWidget {
  const FinishedTimerWheel({
    required this.timer,
    Key? key,
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
