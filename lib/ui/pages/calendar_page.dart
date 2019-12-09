import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/bloc/push/push_bloc.dart';
import 'package:seagull/db/activities_db.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';

class CalendarPage extends StatelessWidget {
  final Authenticated authenticatedState;
  CalendarPage({@required this.authenticatedState});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ActivitiesBloc>(
            builder: (context) => ActivitiesBloc(
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
          builder: (context) => ClockBloc(Ticker.minute()),
        ),
        BlocProvider<DayPickerBloc>(
          builder: (context) => DayPickerBloc(
            clockBloc: BlocProvider.of<ClockBloc>(context),
          ),
        ),
        BlocProvider<DayActivitiesBloc>(
          builder: (context) => DayActivitiesBloc(
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
            dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
          ),
        ),
        BlocProvider<ActivitiesOccasionBloc>(
          builder: (context) => ActivitiesOccasionBloc(
            clockBloc: BlocProvider.of<ClockBloc>(context),
            dayActivitiesBloc: BlocProvider.of<DayActivitiesBloc>(context),
            dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
          ),
        ),
        BlocProvider<AlarmBloc>(
          builder: (context) => AlarmBloc(
            clockBloc: BlocProvider.of<ClockBloc>(context),
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
          ),
        ),
      ],
      child: BlocListener<AlarmBloc, AlarmState>(
        listener: (context, state) async {
          if (state is NewAlarmState) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => AlarmPage(
                        activity: state.activity,
                        atStartTime: state.alarmOnStart,
                        atEndTime: !state.alarmOnStart,
                      ),
                  fullscreenDialog: true),
            );
          } else if (state is NewReminderState) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => ReminderPage(
                        activity: state.activity,
                        reminderTime: state.reminder.inMinutes,
                      ),
                  fullscreenDialog: true),
            );
          }
        },
        child: Calendar(),
      ),
    );
  }
}
