import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarPage extends StatelessWidget {
  final Authenticated authenticatedState;
  CalendarPage({@required this.authenticatedState});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ActivitiesBloc>(
            create: (context) => ActivitiesBloc(
                activitiesRepository: ActivityRepository(
                  client: authenticatedState.userRepository.httpClient,
                  baseUrl: authenticatedState.userRepository.baseUrl,
                  activitiesDb: GetIt.I<ActivityDb>(),
                  authToken: authenticatedState.token,
                  userId: authenticatedState.userId,
                ),
                pushBloc: BlocProvider.of<PushBloc>(context))
              ..add(LoadActivities())),
        BlocProvider<ClockBloc>(
          create: (context) => ClockBloc(GetIt.I<Stream<DateTime>>()),
        ),
        BlocProvider<DayPickerBloc>(
          create: (context) => DayPickerBloc(
            clockBloc: BlocProvider.of<ClockBloc>(context),
          ),
        ),
        BlocProvider<DayActivitiesBloc>(
          create: (context) => DayActivitiesBloc(
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
            dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
          ),
        ),
        BlocProvider<ActivitiesOccasionBloc>(
          create: (context) => ActivitiesOccasionBloc(
            clockBloc: BlocProvider.of<ClockBloc>(context),
            dayActivitiesBloc: BlocProvider.of<DayActivitiesBloc>(context),
            dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
          ),
        ),
        BlocProvider<AlarmBloc>(
          create: (context) => AlarmBloc(
            clockBloc: BlocProvider.of<ClockBloc>(context),
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            selectedNotificationStream: GetIt.I<NotificationStreamGetter>()(),
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
          ),
        ),
        BlocProvider<CalendarViewBloc>(
          create: (context) => CalendarViewBloc(),
        )
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ActivitiesBloc, ActivitiesState>(
            listener: (context, state) async {
              if (state is ActivitiesLoaded) {
                final scheduleAlarm = GetIt.I<AlarmScheduler>();
                await scheduleAlarm(state.activities, forDuration: 24.hours());
              }
            },
          ),
          BlocListener<AlarmBloc, AlarmStateBase>(
            listener: _alarmListener,
          ),
          BlocListener<NotificationBloc, AlarmStateBase>(
            listener: _alarmListener,
          ),
        ],
        child: Calendar(),
      ),
    );
  }

  void _alarmListener(BuildContext context, AlarmStateBase state) async {
    if (state is AlarmState) {
      final alarm = state.alarm;
      final navigator = Navigator.of(context);
      if (alarm is NewAlarm) {
        await navigator.push(
          MaterialPageRoute(
            builder: (context) => AlarmPage(
              activity: alarm.activity,
              atStartTime: alarm.alarmOnStart,
              atEndTime: !alarm.alarmOnStart,
            ),
            fullscreenDialog: true,
          ),
        );
      } else if (alarm is NewReminder) {
        await navigator.push(
          MaterialPageRoute(
            builder: (context) => ReminderPage(
              activity: alarm.activity,
              reminderTime: alarm.reminder.inMinutes,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    }
  }
}
