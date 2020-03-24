import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/bloc/user_file/user_file_bloc.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarPage extends StatelessWidget {
  final Authenticated authenticatedState;
  CalendarPage({@required this.authenticatedState});
  @override
  Widget build(BuildContext context) {
    final activityRepository = ActivityRepository(
      client: authenticatedState.userRepository.httpClient,
      baseUrl: authenticatedState.userRepository.baseUrl,
      activityDb: GetIt.I<ActivityDb>(),
      userId: authenticatedState.userId,
      authToken: authenticatedState.token,
    );
    final userFileRepository = UserFileRepository(
      httpClient: authenticatedState.userRepository.httpClient,
      baseUrl: authenticatedState.userRepository.baseUrl,
      userFileDb: GetIt.I<UserFileDb>(),
      fileStorage: GetIt.I<FileStorage>(),
      userId: authenticatedState.userId,
      authToken: authenticatedState.token,
      multipartRequestBuilder: GetIt.I<MultipartRequestBuilder>(),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<SyncBloc>(
          create: (context) => SyncBloc(
            activityRepository: activityRepository,
            userFileRepository: userFileRepository,
          ),
        ),
        BlocProvider<ActivitiesBloc>(
          create: (context) => ActivitiesBloc(
            activityRepository: activityRepository,
            syncBloc: BlocProvider.of<SyncBloc>(context),
            pushBloc: BlocProvider.of<PushBloc>(context),
          )..add(LoadActivities()),
        ),
        BlocProvider<UserFileBloc>(
          create: (context) => UserFileBloc(
            userFileRepository: userFileRepository,
            syncBloc: BlocProvider.of<SyncBloc>(context),
            fileStorage: GetIt.I<FileStorage>(),
            pushBloc: BlocProvider.of<PushBloc>(context),
          ),
        ),
        BlocProvider<SortableBloc>(
          create: (context) => SortableBloc(
            sortableRepository: SortableRepository(
              baseUrl: authenticatedState.userRepository.baseUrl,
              client: authenticatedState.userRepository.httpClient,
              sortableDb: GetIt.I<SortableDb>(),
              userId: authenticatedState.userId,
              authToken: authenticatedState.token,
            ),
            pushBloc: BlocProvider.of<PushBloc>(context),
          )..add(LoadSortables()),
        ),
        BlocProvider<ClockBloc>(
          create: (context) => ClockBloc(
            GetIt.I<Stream<DateTime>>(),
            initialTime: GetIt.I<DateTime>(),
          ),
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
        ),
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
      await GetIt.I<AlarmNavigator>().pushAlarm(
          context, state.alarm, BlocProvider.of<ActivitiesBloc>(context));
    }
  }
}
