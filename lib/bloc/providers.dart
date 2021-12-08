import 'package:flutter/material.dart';

import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

class AuthenticatedBlocsProvider extends StatelessWidget {
  final Authenticated authenticatedState;
  final Widget child;
  final MemoplannerSettingBloc? memoplannerSettingBloc;
  final SortableBloc? sortableBloc;

  AuthenticatedBlocsProvider({
    required this.authenticatedState,
    required this.child,
    this.memoplannerSettingBloc,
    this.sortableBloc,
    Key? key,
  }) : super(key: key) {
    ensureNotificationPluginInitialized();
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ActivityRepository>(
            create: (context) => ActivityRepository(
              client: authenticatedState.userRepository.client,
              baseUrl: authenticatedState.userRepository.baseUrl,
              activityDb: GetIt.I<ActivityDb>(),
              userId: authenticatedState.userId,
              authToken: authenticatedState.token,
            ),
          ),
          RepositoryProvider<UserFileRepository>(
            create: (context) => UserFileRepository(
              client: authenticatedState.userRepository.client,
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
              client: authenticatedState.userRepository.client,
              sortableDb: GetIt.I<SortableDb>(),
              userId: authenticatedState.userId,
              authToken: authenticatedState.token,
            ),
          ),
          RepositoryProvider<GenericRepository>(
            create: (context) => GenericRepository(
              baseUrl: authenticatedState.userRepository.baseUrl,
              client: authenticatedState.userRepository.client,
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
                activityRepository: context.read<ActivityRepository>(),
                userFileRepository: context.read<UserFileRepository>(),
                sortableRepository: context.read<SortableRepository>(),
                genericRepository: context.read<GenericRepository>(),
                syncDelay: GetIt.I<SyncDelays>(),
              ),
            ),
            BlocProvider<ActivitiesBloc>(
              create: (context) => ActivitiesBloc(
                activityRepository: context.read<ActivityRepository>(),
                syncBloc: context.read<SyncBloc>(),
                pushBloc: context.read<PushBloc>(),
              )..add(LoadActivities()),
            ),
            BlocProvider<WeekCalendarBloc>(
              create: (context) => WeekCalendarBloc(
                activitiesBloc: context.read<ActivitiesBloc>(),
                clockBloc: context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<MonthCalendarBloc>(
              create: (context) => MonthCalendarBloc(
                activitiesBloc: context.read<ActivitiesBloc>(),
                clockBloc: context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<UserFileBloc>(
              create: (context) => UserFileBloc(
                userFileRepository: context.read<UserFileRepository>(),
                syncBloc: context.read<SyncBloc>(),
                fileStorage: GetIt.I<FileStorage>(),
                pushBloc: context.read<PushBloc>(),
              )..add(LoadUserFiles()),
              lazy: false,
            ),
            BlocProvider<SortableBloc>(
              create: (context) => sortableBloc ??
                  SortableBloc(
                    sortableRepository: context.read<SortableRepository>(),
                    syncBloc: context.read<SyncBloc>(),
                    pushBloc: context.read<PushBloc>(),
                  )
                ..add(const LoadSortables(initDefaults: true)),
              lazy: false,
            ),
            BlocProvider<GenericBloc>(
              create: (context) => GenericBloc(
                genericRepository: context.read<GenericRepository>(),
                syncBloc: context.read<SyncBloc>(),
                pushBloc: context.read<PushBloc>(),
              )..add(LoadGenerics()),
            ),
            BlocProvider<MemoplannerSettingBloc>(
              create: (context) =>
                  memoplannerSettingBloc ??
                  MemoplannerSettingBloc(
                    genericBloc: context.read<GenericBloc>(),
                  ),
            ),
            BlocProvider<DayPickerBloc>(
              create: (context) => DayPickerBloc(
                clockBloc: context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<DayActivitiesBloc>(
              create: (context) => DayActivitiesBloc(
                activitiesBloc: context.read<ActivitiesBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
              ),
            ),
            BlocProvider<ActivitiesOccasionBloc>(
              create: (context) => ActivitiesOccasionBloc(
                clockBloc: context.read<ClockBloc>(),
                dayActivitiesBloc: context.read<DayActivitiesBloc>(),
              ),
            ),
            BlocProvider<AlarmCubit>(
              create: (context) => AlarmCubit(
                clockBloc: context.read<ClockBloc>(),
                activitiesBloc: context.read<ActivitiesBloc>(),
              ),
            ),
            BlocProvider<NotificationCubit>(
              create: (context) => NotificationCubit(
                selectedNotificationSubject: selectNotificationSubject,
              ),
            ),
            BlocProvider<CalendarViewCubit>(
              create: (context) => CalendarViewCubit(
                GetIt.I<SettingsDb>(),
              ),
            ),
            BlocProvider<LicenseBloc>(
              create: (context) => LicenseBloc(
                clockBloc: context.read<ClockBloc>(),
                pushBloc: context.read<PushBloc>(),
                userRepository: authenticatedState.userRepository,
                authenticationBloc: context.read<AuthenticationBloc>(),
              )..add(ReloadLicenses()),
            ),
            BlocProvider<PermissionBloc>(
              create: (context) => PermissionBloc()
                ..add(const RequestPermissions([Permission.notification]))
                ..checkAll(),
            ),
            BlocProvider<TimepillarCubit>(
              create: (context) => TimepillarCubit(
                clockBloc: context.read<ClockBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
              ),
            ),
            if (Config.isMP)
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback: SystemSettingsEditor.screenOffTimeout,
                  battery: GetIt.I<Battery>(),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                ),
              ),
          ],
          child: child,
        ),
      );
}

class TopLevelBlocsProvider extends StatelessWidget {
  final Widget child;
  final PushBloc? pushBloc;
  final String baseUrl;

  const TopLevelBlocsProvider({
    Key? key,
    required this.child,
    required this.baseUrl,
    this.pushBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>(
      create: (context) => UserRepository(
        baseUrl: baseUrl,
        client: GetIt.I<BaseClient>(),
        tokenDb: GetIt.I<TokenDb>(),
        userDb: GetIt.I<UserDb>(),
        licenseDb: GetIt.I<LicenseDb>(),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              context.read<UserRepository>(),
              onLogout: () => Future.wait<void>(
                [
                  DatabaseRepository.clearAll(GetIt.I<Database>()),
                  GetIt.I<SeagullLogger>().sendLogsToBackend(),
                  clearNotificationSubject(),
                  notificationPlugin.cancelAll(),
                  GetIt.I<FileStorage>().deleteUserFolder(),
                ],
              ),
            )..add(CheckAuthentication()),
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
          if (Config.isMP)
            BlocProvider<InactivityCubit>(
              create: (context) => InactivityCubit(
                const Duration(minutes: 6),
                context.read<ClockBloc>(),
              ),
            ),
        ],
        child: child,
      ),
    );
  }
}

class CopiedAuthProviders extends StatelessWidget {
  final Widget child;
  final BuildContext blocContext;

  const CopiedAuthProviders({
    Key? key,
    required this.blocContext,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DON'T change  to
    // BlocProvider<Bloc>( create: ...
    // since create closes the blocs when widget is destroyed
    return MultiBlocProvider(
      providers: [
        BlocProvider<SyncBloc>.value(
          value: blocContext.read<SyncBloc>(),
        ),
        BlocProvider<ActivitiesBloc>.value(
          value: blocContext.read<ActivitiesBloc>(),
        ),
        BlocProvider<UserFileBloc>.value(
          value: blocContext.read<UserFileBloc>(),
        ),
        BlocProvider<SortableBloc>.value(
          value: blocContext.read<SortableBloc>(),
        ),
        BlocProvider<GenericBloc>.value(
          value: blocContext.read<GenericBloc>(),
        ),
        BlocProvider<MemoplannerSettingBloc>.value(
          value: blocContext.read<MemoplannerSettingBloc>(),
        ),
        BlocProvider<DayPickerBloc>.value(
          value: blocContext.read<DayPickerBloc>(),
        ),
        BlocProvider<DayActivitiesBloc>.value(
          value: blocContext.read<DayActivitiesBloc>(),
        ),
        BlocProvider<ActivitiesOccasionBloc>.value(
          value: blocContext.read<ActivitiesOccasionBloc>(),
        ),
        BlocProvider<AlarmCubit>.value(
          value: blocContext.read<AlarmCubit>(),
        ),
        BlocProvider<NotificationCubit>.value(
          value: blocContext.read<NotificationCubit>(),
        ),
        BlocProvider<CalendarViewCubit>.value(
          value: blocContext.read<CalendarViewCubit>(),
        ),
        BlocProvider<LicenseBloc>.value(
          value: blocContext.read<LicenseBloc>(),
        ),
        BlocProvider<PermissionBloc>.value(
          value: blocContext.read<PermissionBloc>(),
        ),
        BlocProvider<TimepillarCubit>.value(
          value: blocContext.read<TimepillarCubit>(),
        ),
        if (Config.isMP)
          BlocProvider<WakeLockCubit>.value(
            value: blocContext.read<WakeLockCubit>(),
          ),
      ],
      child: child,
    );
  }
}
