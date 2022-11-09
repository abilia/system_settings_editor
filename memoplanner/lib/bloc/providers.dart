import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/transformers.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/repository/session_repository.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class AuthenticatedBlocsProvider extends StatelessWidget {
  final Authenticated authenticatedState;
  final Widget child;
  final MemoplannerSettingsBloc? memoplannerSettingBloc;
  final SortableBloc? sortableBloc;
  final SyncBloc? syncBloc;

  AuthenticatedBlocsProvider({
    required this.authenticatedState,
    required this.child,
    this.memoplannerSettingBloc,
    this.sortableBloc,
    this.syncBloc,
    Key? key,
  }) : super(key: key) {
    ensureNotificationPluginInitialized();
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ActivityRepository>(
            create: (context) => ActivityRepository(
              client: GetIt.I<ListenableClient>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              activityDb: GetIt.I<ActivityDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<UserFileRepository>(
            create: (context) => UserFileRepository(
              client: GetIt.I<ListenableClient>(),
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
              client: GetIt.I<ListenableClient>(),
              sortableDb: GetIt.I<SortableDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<GenericRepository>(
            create: (context) => GenericRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<ListenableClient>(),
              genericDb: GetIt.I<GenericDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<SessionRepository>(
            create: (context) => SessionRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<ListenableClient>(),
              sessionsDb: GetIt.I<SessionsDb>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SyncBloc>(
              create: (context) =>
                  syncBloc ??
                  (SyncBloc(
                    pushCubit: context.read<PushCubit>(),
                    licenseCubit: context.read<LicenseCubit>(),
                    activityRepository: context.read<ActivityRepository>(),
                    userFileRepository: context.read<UserFileRepository>(),
                    sortableRepository: context.read<SortableRepository>(),
                    genericRepository: context.read<GenericRepository>(),
                    syncDelay: GetIt.I<SyncDelays>(),
                  )..add(const SyncAll())),
              lazy: false,
            ),
            BlocProvider<ActivitiesBloc>(
              create: (context) => ActivitiesBloc(
                activityRepository: context.read<ActivityRepository>(),
                syncBloc: context.read<SyncBloc>(),
              ),
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
                activityRepository: context.read<ActivityRepository>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
                clockBloc: context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<UserFileCubit>(
              create: (context) => UserFileCubit(
                userFileRepository: context.read<UserFileRepository>(),
                syncBloc: context.read<SyncBloc>(),
                fileStorage: GetIt.I<FileStorage>(),
              )..loadUserFiles(),
              lazy: false,
            ),
            BlocProvider<SortableBloc>(
              create: (context) =>
                  sortableBloc ??
                  SortableBloc(
                    sortableRepository: context.read<SortableRepository>(),
                    syncBloc: context.read<SyncBloc>(),
                  ),
              lazy: false,
            ),
            BlocProvider<GenericCubit>(
              create: (context) => GenericCubit(
                genericRepository: context.read<GenericRepository>(),
                syncBloc: context.read<SyncBloc>(),
              )..loadGenerics(),
            ),
            BlocProvider<MemoplannerSettingsBloc>(
              create: (context) =>
                  memoplannerSettingBloc ??
                  MemoplannerSettingsBloc(
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
                activityRepository: context.read<ActivityRepository>(),
                clockBloc: context.read<ClockBloc>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
              )..initialize(),
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
                activityRepository: context.read<ActivityRepository>(),
                settingsBloc: context.read<MemoplannerSettingsBloc>(),
                selectedNotificationSubject: selectNotificationSubject,
                timerAlarm: context
                    .read<TimerAlarmBloc>()
                    .stream
                    .map((event) => event.firedAlarm)
                    .whereNotNull(),
              ),
            ),
            BlocProvider<CalendarViewCubit>(
              create: (context) => CalendarViewCubit(
                GetIt.I<SettingsDb>(),
              ),
            ),
            BlocProvider<PermissionCubit>(
              create: (context) => PermissionCubit()
                ..requestPermissions([Permission.notification])
                ..checkAll(),
            ),
            BlocProvider<DayPartCubit>(
              create: (context) => DayPartCubit(
                context.read<MemoplannerSettingsBloc>(),
                context.read<ClockBloc>(),
              ),
            ),
            BlocProvider<TimepillarCubit>(
              create: (context) => TimepillarCubit(
                clockBloc: context.read<ClockBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                memoSettingsBloc: context.read<MemoplannerSettingsBloc>(),
                activitiesBloc: context.read<ActivitiesBloc>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
                dayPartCubit: context.read<DayPartCubit>(),
              ),
            ),
            BlocProvider<TimepillarMeasuresCubit>(
              create: (context) => TimepillarMeasuresCubit(
                timepillarCubit: context.read<TimepillarCubit>(),
                memoplannerSettingsBloc:
                    context.read<MemoplannerSettingsBloc>(),
              ),
            ),
            BlocProvider<NotificationBloc>(
              create: (context) => NotificationBloc(
                memoplannerSettingBloc: context.read<MemoplannerSettingsBloc>(),
                activityRepository: context.read<ActivityRepository>(),
                settingsDb: GetIt.I<SettingsDb>(),
                timerDb: GetIt.I<TimerDb>(),
                syncDelays: GetIt.I<SyncDelays>(),
              ),
            ),
            BlocProvider<SessionCubit>(
              create: (context) => SessionCubit(
                sessionRepository: context.read<SessionRepository>(),
              ),
              lazy: false,
            ),
            if (Config.isMP) ...[
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback: SystemSettingsEditor.screenOffTimeout,
                  battery: GetIt.I<Battery>(),
                  memoSettingsBloc: context.read<MemoplannerSettingsBloc>(),
                ),
              ),
              BlocProvider<InactivityCubit>(
                create: (context) => InactivityCubit(
                  GetIt.I<Ticker>(),
                  context.read<MemoplannerSettingsBloc>(),
                  context.read<DayPartCubit>(),
                  context.read<TouchDetectionCubit>().stream,
                  context.read<AlarmCubit>().stream,
                  context.read<TimerAlarmBloc>().stream,
                ),
              ),
              BlocProvider<ActionIntentCubit>(
                create: (context) => ActionIntentCubit(
                  GetIt.I<ActionIntentStream>(),
                ),
              ),
            ]
          ],
          child: child,
        ),
      );
}

class TopLevelProvider extends StatelessWidget {
  const TopLevelProvider({
    required this.child,
    Key? key,
    this.pushCubit,
  }) : super(key: key);

  final Widget child;
  final PushCubit? pushCubit;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
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
            client: GetIt.I<ListenableClient>(),
            deviceDb: GetIt.I<DeviceDb>(),
          ),
        ),
        if (Config.isMP) ...[
          RepositoryProvider<VoiceRepository>(
            create: (context) => VoiceRepository(
              client: GetIt.I<ListenableClient>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              applicationSupportDirectory:
                  GetIt.I<Directories>().applicationSupport,
              tempDirectory: GetIt.I<Directories>().temp,
              ttsHandler: GetIt.I<TtsInterface>(),
            ),
          ),
        ],
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PushCubit>(
            create: (context) => pushCubit ?? PushCubit(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider(
            create: (context) => StartupCubit(
              deviceRepository: context.read<DeviceRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BaseUrlCubit(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
            ),
          ),
          BlocProvider(
            create: (context) => LocaleCubit(GetIt.I<SettingsDb>()),
          ),
          BlocProvider(
            create: (context) => TouchDetectionCubit(),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => SpeechSettingsCubit(
              voiceDb: GetIt.I<VoiceDb>(),
              acapelaTts: GetIt.I<TtsInterface>(),
            ),
          ),
          if (Config.isMP)
            BlocProvider<VoicesCubit>(
              create: (context) => VoicesCubit(
                languageCode: GetIt.I<SettingsDb>().language,
                speechSettingsCubit: context.read<SpeechSettingsCubit>(),
                voiceRepository: context.read<VoiceRepository>(),
                localeStream: context.read<LocaleCubit>().stream,
              )..initialize(),
              lazy: false,
            ),
        ],
        child: child,
      ),
    );
  }
}

class AuthenticationBlocProvider extends StatelessWidget {
  const AuthenticationBlocProvider({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
                GetIt.I<SupportPersonsDb>().deleteAll(),
                GetIt.I<LicenseDb>().delete(),
                GetIt.I<SettingsDb>().restore(),
                GetIt.I<SessionsDb>().setHasMP4Session(false),
              ],
            ),
            client: GetIt.I<ListenableClient>(),
          )..add(CheckAuthentication()),
        ),
        BlocProvider<LicenseCubit>(
          create: (context) => LicenseCubit(
            clockBloc: context.read<ClockBloc>(),
            pushCubit: context.read<PushCubit>(),
            userRepository: context.read<UserRepository>(),
            authenticationBloc: context.read<AuthenticationBloc>(),
          )..reloadLicenses(),
        ),
      ],
      child: child,
    );
  }
}
