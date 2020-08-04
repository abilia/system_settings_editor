import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/settings_bloc.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/bloc/user_file/user_file_bloc.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

class AuthenticatedBlocsProvider extends StatelessWidget {
  final Authenticated authenticatedState;
  final Widget child;
  AuthenticatedBlocsProvider({
    @required this.authenticatedState,
    @required this.child,
  }) {
    ensureNotificationPluginInitialized();
  }
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ActivityRepository>(
          create: (context) => ActivityRepository(
            client: authenticatedState.userRepository.httpClient,
            baseUrl: authenticatedState.userRepository.baseUrl,
            activityDb: GetIt.I<ActivityDb>(),
            userId: authenticatedState.userId,
            authToken: authenticatedState.token,
          ),
        ),
        RepositoryProvider<UserFileRepository>(
          create: (context) => UserFileRepository(
            httpClient: authenticatedState.userRepository.httpClient,
            baseUrl: authenticatedState.userRepository.baseUrl,
            userFileDb: GetIt.I<UserFileDb>(),
            fileStorage: GetIt.I<FileStorage>(),
            userId: authenticatedState.userId,
            authToken: authenticatedState.token,
            multipartRequestBuilder: GetIt.I<MultipartRequestBuilder>(),
          ),
        ),
        RepositoryProvider<SortableRepository>(
          create: (context) => SortableRepository(
            baseUrl: authenticatedState.userRepository.baseUrl,
            client: authenticatedState.userRepository.httpClient,
            sortableDb: GetIt.I<SortableDb>(),
            userId: authenticatedState.userId,
            authToken: authenticatedState.token,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SyncBloc>(
            create: (context) => SyncBloc(
              activityRepository: context.repository<ActivityRepository>(),
              userFileRepository: context.repository<UserFileRepository>(),
              sortableRepository: context.repository<SortableRepository>(),
              syncDelay: GetIt.I<SyncDelays>(),
            ),
          ),
          BlocProvider<ActivitiesBloc>(
            create: (context) => ActivitiesBloc(
              activityRepository: context.repository<ActivityRepository>(),
              syncBloc: context.bloc<SyncBloc>(),
              pushBloc: context.bloc<PushBloc>(),
            )..add(LoadActivities()),
          ),
          BlocProvider<UserFileBloc>(
            create: (context) => UserFileBloc(
              userFileRepository: context.repository<UserFileRepository>(),
              syncBloc: context.bloc<SyncBloc>(),
              fileStorage: GetIt.I<FileStorage>(),
              pushBloc: context.bloc<PushBloc>(),
            ),
          ),
          BlocProvider<SortableBloc>(
            create: (context) => SortableBloc(
              sortableRepository: context.repository<SortableRepository>(),
              syncBloc: context.bloc<SyncBloc>(),
              pushBloc: context.bloc<PushBloc>(),
            )..add(LoadSortables()),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider<DayPickerBloc>(
            create: (context) => DayPickerBloc(
              clockBloc: context.bloc<ClockBloc>(),
            ),
          ),
          BlocProvider<DayActivitiesBloc>(
            create: (context) => DayActivitiesBloc(
              activitiesBloc: context.bloc<ActivitiesBloc>(),
              dayPickerBloc: context.bloc<DayPickerBloc>(),
            ),
          ),
          BlocProvider<ActivitiesOccasionBloc>(
            create: (context) => ActivitiesOccasionBloc(
              clockBloc: context.bloc<ClockBloc>(),
              dayActivitiesBloc: context.bloc<DayActivitiesBloc>(),
            ),
          ),
          BlocProvider<AlarmBloc>(
            create: (context) => AlarmBloc(
              clockBloc: context.bloc<ClockBloc>(),
              activitiesBloc: context.bloc<ActivitiesBloc>(),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              selectedNotificationStream: GetIt.I<NotificationStreamGetter>()(),
              activitiesBloc: context.bloc<ActivitiesBloc>(),
            ),
          ),
          BlocProvider<CalendarViewBloc>(
            create: (context) => CalendarViewBloc(),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: GetIt.I<SettingsDb>(),
            ),
          )
        ],
        child: child,
      ),
    );
  }
}
