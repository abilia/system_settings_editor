import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/bloc/user_file/user_file_bloc.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

class AuthenticatedBlocsProvider extends StatelessWidget {
  final Authenticated authenticatedState;
  final Widget child;
  final MemoplannerSettingBloc memoplannerSettingBloc;
  AuthenticatedBlocsProvider({
    @required this.authenticatedState,
    @required this.child,
    this.memoplannerSettingBloc,
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
        RepositoryProvider<GenericRepository>(
          create: (context) => GenericRepository(
            baseUrl: authenticatedState.userRepository.baseUrl,
            client: authenticatedState.userRepository.httpClient,
            genericDb: GetIt.I<GenericDb>(),
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
          BlocProvider<GenericBloc>(
            create: (context) => GenericBloc(
              genericRepository: context.repository<GenericRepository>(),
              syncBloc: context.bloc<SyncBloc>(),
              pushBloc: context.bloc<PushBloc>(),
            )..add(LoadGenerics()),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) =>
                memoplannerSettingBloc ??
                MemoplannerSettingBloc(
                  genericBloc: context.bloc<GenericBloc>(),
                ),
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
              selectedNotificationSubject: GetIt.I<ReplaySubject<String>>(),
            ),
          ),
          BlocProvider<CalendarViewBloc>(
            create: (context) => CalendarViewBloc(),
          ),
          BlocProvider<LicenseBloc>(
            create: (context) => LicenseBloc(
              clockBloc: context.bloc<ClockBloc>(),
              pushBloc: context.bloc<PushBloc>(),
              userRepository: authenticatedState.userRepository,
              authenticationBloc: context.repository<AuthenticationBloc>(),
            )..add(ReloadLicenses()),
          ),
          BlocProvider<PermissionBloc>(
            create: (context) => PermissionBloc()
              ..add(RequestPermission(Permission.notification))
              ..checkAll(),
          ),
        ],
        child: child,
      ),
    );
  }
}

class TopLevelBlocsProvider extends StatelessWidget {
  final Widget child;
  final PushBloc pushBloc;
  final String baseUrl;
  const TopLevelBlocsProvider({
    Key key,
    @required this.child,
    @required this.baseUrl,
    this.pushBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>(
      create: (context) => UserRepository(
        baseUrl: baseUrl,
        httpClient: GetIt.I<BaseClient>(),
        tokenDb: GetIt.I<TokenDb>(),
        userDb: GetIt.I<UserDb>(),
        licenseDb: GetIt.I<LicenseDb>(),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              database: GetIt.I<Database>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              seagullLogger: GetIt.I<SeagullLogger>(),
              cancleAllNotificationsFunction: () =>
                  notificationPlugin.cancelAll(),
            )..add(AppStarted(context.repository<UserRepository>())),
          ),
          BlocProvider<PushBloc>(
            create: (context) => pushBloc ?? PushBloc(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: GetIt.I<SettingsDb>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
