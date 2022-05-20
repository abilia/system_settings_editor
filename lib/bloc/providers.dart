import 'package:flutter/material.dart';

import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
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
              client: GetIt.I<BaseClient>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              activityDb: GetIt.I<ActivityDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<UserFileRepository>(
            create: (context) => UserFileRepository(
              client: GetIt.I<BaseClient>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              userFileDb: GetIt.I<UserFileDb>(),
              fileStorage: GetIt.I<FileStorage>(),
              loginDb: GetIt.I<LoginDb>(),
              userId: authenticatedState.userId,
              multipartRequestBuilder: GetIt.I<MultipartRequestBuilder>(),
            ),
          ),
          RepositoryProvider<SortableRepository>(
            create: (context) => SortableRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<BaseClient>(),
              sortableDb: GetIt.I<SortableDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<GenericRepository>(
            create: (context) => GenericRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<BaseClient>(),
              genericDb: GetIt.I<GenericDb>(),
              userId: authenticatedState.userId,
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
                pushCubit: context.read<PushCubit>(),
              )..add(LoadActivities()),
            ),
            BlocProvider<TimerCubit>(
              create: (context) => TimerCubit(
                timerDb: GetIt.I<TimerDb>(),
                ticker: GetIt.I<Ticker>(),
              )..loadTimers(),
            ),
            BlocProvider(
              create: (context) => TimerAlarmBloc(
                ticker: GetIt.I<Ticker>(),
                timerCubit: context.read<TimerCubit>(),
              ),
            ),
            BlocProvider<WeekCalendarCubit>(
              create: (context) => WeekCalendarCubit(
                activitiesBloc: context.read<ActivitiesBloc>(),
                clockBloc: context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<UserFileCubit>(
              create: (context) => UserFileCubit(
                userFileRepository: context.read<UserFileRepository>(),
                syncBloc: context.read<SyncBloc>(),
                fileStorage: GetIt.I<FileStorage>(),
                pushCubit: context.read<PushCubit>(),
              )..loadUserFiles(),
              lazy: false,
            ),
            BlocProvider<SortableBloc>(
              create: (context) => sortableBloc ??
                  SortableBloc(
                    sortableRepository: context.read<SortableRepository>(),
                    syncBloc: context.read<SyncBloc>(),
                    pushCubit: context.read<PushCubit>(),
                  )
                ..add(const LoadSortables(initDefaults: true)),
              lazy: false,
            ),
            BlocProvider<GenericCubit>(
              create: (context) => GenericCubit(
                genericRepository: context.read<GenericRepository>(),
                syncBloc: context.read<SyncBloc>(),
                pushCubit: context.read<PushCubit>(),
              )..loadGenerics(),
            ),
            BlocProvider<MemoplannerSettingBloc>(
              create: (context) =>
                  memoplannerSettingBloc ??
                  MemoplannerSettingBloc(
                    genericCubit: context.read<GenericCubit>(),
                  ),
            ),
            BlocProvider<DayPickerBloc>(
              create: (context) => DayPickerBloc(
                clockBloc: context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<MonthCalendarCubit>(
              create: (context) => MonthCalendarCubit(
                activitiesBloc: context.read<ActivitiesBloc>(),
                clockBloc: context.read<ClockBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
              ),
            ),
            BlocProvider<DayEventsCubit>(
              create: (context) => DayEventsCubit(
                activitiesBloc: context.read<ActivitiesBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
              ),
            ),
            BlocProvider<AlarmCubit>(
              create: (context) => AlarmCubit(
                clockBloc: context.read<ClockBloc>(),
                activitiesBloc: context.read<ActivitiesBloc>(),
                selectedNotificationSubject: selectNotificationSubject,
              ),
            ),
            BlocProvider<CalendarViewCubit>(
              create: (context) => CalendarViewCubit(
                GetIt.I<SettingsDb>(),
              ),
            ),
            BlocProvider<LicenseCubit>(
              create: (context) => LicenseCubit(
                clockBloc: context.read<ClockBloc>(),
                pushCubit: context.read<PushCubit>(),
                userRepository: context.read<UserRepository>(),
                authenticationBloc: context.read<AuthenticationBloc>(),
              )..reloadLicenses(),
            ),
            BlocProvider<PermissionCubit>(
              create: (context) => PermissionCubit()
                ..requestPermissions([Permission.notification])
                ..checkAll(),
            ),
            BlocProvider<TimepillarCubit>(
              create: (context) => TimepillarCubit(
                clockBloc: context.read<ClockBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                activitiesBloc: context.read<ActivitiesBloc>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
              ),
            ),
            BlocProvider<TimepillarMeasuresCubit>(
              create: (context) => TimepillarMeasuresCubit(
                timepillarCubit: context.read<TimepillarCubit>(),
                memoplannerSettingsBloc: context.read<MemoplannerSettingBloc>(),
              ),
            ),
            if (Config.isMP) ...[
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback: SystemSettingsEditor.screenOffTimeout,
                  battery: GetIt.I<Battery>(),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                ),
              ),
              BlocProvider<InactivityCubit>(
                create: (context) => InactivityCubit(
                  const Duration(minutes: 5),
                  GetIt.I<Ticker>(),
                  context.read<MemoplannerSettingBloc>(),
                  context.read<TouchDetectionCubit>().stream,
                ),
              ),
            ]
          ],
          child: child,
        ),
      );
}

class TopLevelBlocsProvider extends StatelessWidget {
  const TopLevelBlocsProvider({
    Key? key,
    required this.child,
    required this.runStartGuide,
    this.pushCubit,
  }) : super(key: key);

  final Widget child;
  final PushCubit? pushCubit;
  final bool runStartGuide;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<BaseClient>(),
            loginDb: GetIt.I<LoginDb>(),
            userDb: GetIt.I<UserDb>(),
            licenseDb: GetIt.I<LicenseDb>(),
            deviceDb: GetIt.I<DeviceDb>(),
            calendarDb: GetIt.I<CalendarDb>(),
          ),
        ),
        RepositoryProvider<DeviceRepository>(
          create: (context) => DeviceRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<BaseClient>(),
            deviceDb: GetIt.I<DeviceDb>(),
          ),
        ),
      ],
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
          BlocProvider<PushCubit>(
            create: (context) => pushCubit ?? PushCubit(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
              settingsDb: GetIt.I<SettingsDb>(),
            ),
          ),
          BlocProvider(
            create: (context) => StartGuideCubit(
              deviceRepository: context.read<DeviceRepository>(),
              runStartGuide: runStartGuide,
            ),
          ),
          BlocProvider(
            create: (context) => BaseUrlCubit(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
            ),
          ),
          if (Config.isMP)
            BlocProvider(
              create: (context) => TouchDetectionCubit(),
            ),
        ],
        child: child,
      ),
    );
  }
}
