import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmPage extends StatelessWidget {
  final NewAlarm alarm;
  final Widget? previewImage;

  const AlarmPage({
    Key? key,
    required this.alarm,
    this.previewImage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, activitiesState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) {
          return Scaffold(
            appBar: AbiliaAppBar(
              title: Translator.of(context).translate.alarm,
              iconData: AbiliaIcons.alarm_bell,
              trailing: alarm is StartAlarm &&
                      alarm.activity.extras.startTimeExtraAlarm.isNotEmpty
                  ? PlaySpeechButton(
                      soundToPlay: alarm.activity.extras.startTimeExtraAlarm)
                  : alarm is EndAlarm &&
                          alarm.activity.extras.endTimeExtraAlarm.isNotEmpty
                      ? PlaySpeechButton(
                          soundToPlay: alarm.activity.extras.endTimeExtraAlarm)
                      : null,
            ),
            body: Padding(
              padding: EdgeInsets.all(ActivityInfo.margin),
              child: ActivityInfo(
                alarm.activityDay.fromActivitiesState(activitiesState),
                previewImage: previewImage,
                alarm: alarm,
              ),
            ),
            bottomNavigationBar: AlarmBottomAppBar(
              activityOccasion: alarm.activityDay.toOccasion(alarm.day),
              alarm: alarm,
            ),
          );
        },
      ),
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
          title: translate.reminder, iconData: AbiliaIcons.handi_reminder),
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
              child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
                builder: (context, activitiesState) => ActivityInfo(
                  reminder.activityDay.fromActivitiesState(activitiesState),
                  alarm: reminder,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AlarmBottomAppBar(
        activityOccasion: reminder.activityDay.toOccasion(reminder.day),
        alarm: reminder,
      ),
    );
  }
}

class PopAwareAlarmPage extends StatelessWidget {
  final Widget child;
  final AlarmNavigator alarmNavigator;
  final NotificationAlarm alarm;

  const PopAwareAlarmPage({
    Key? key,
    required this.alarm,
    required this.alarmNavigator,
    required this.child,
  });

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
    required this.activityOccasion,
    required this.alarm,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final NotificationAlarm alarm;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final displayCheckButton =
        activityOccasion.activity.checkable && !activityOccasion.isSignedOff;
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
                    icon: AbiliaIcons.handi_check,
                    onPressed: () async {
                      final checked =
                          await checkConfirmation(context, activityOccasion);
                      if (checked == true) {
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

class PlaySpeechButton extends StatelessWidget {
  final AbiliaFile soundToPlay;

  PlaySpeechButton({required this.soundToPlay});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SoundCubit(),
      child: BlocBuilder<UserFileBloc, UserFileState>(
        builder: (context, state) {
          return PlaySoundButton(
            sound: context.read<UserFileBloc>().state.getFile(
                  soundToPlay,
                  GetIt.I<FileStorage>(),
                ),
            buttonStyle: actionButtonStyleLight,
          );
        },
      ),
    );
  }
}
