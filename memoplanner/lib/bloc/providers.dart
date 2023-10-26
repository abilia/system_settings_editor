// ignore_for_file: discarded_futures

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:calendar/all.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/repository/sessions_repository.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:rxdart/transformers.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_to_speech/text_to_speech.dart';

class AuthenticatedBlocsProvider extends StatelessWidget {
  final Authenticated authenticatedState;
  final Widget child;
  final MemoplannerSettingsBloc? memoplannerSettingBloc;
  final SortableBloc? sortableBloc;
  final SyncBloc? syncBloc;

  const AuthenticatedBlocsProvider({
    required this.authenticatedState,
    required this.child,
    this.memoplannerSettingBloc,
    this.sortableBloc,
    this.syncBloc,
    super.key,
  });

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
              noSyncSettings: MemoplannerSettings.noSyncSettings,
              type: MemoplannerSettingData.genericType,
            ),
          ),
          RepositoryProvider<SessionsRepository>(
            create: (context) => SessionsRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<ListenableClient>(),
              sessionsDb: GetIt.I<SessionsDb>(),
            ),
          ),
          RepositoryProvider<TermsOfUseRepository>(
            create: (context) => TermsOfUseRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<ListenableClient>(),
              termsOfUseDb: GetIt.I<TermsOfUseDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<SupportPersonsRepository>(
            lazy: false,
            create: (context) => SupportPersonsRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<ListenableClient>(),
              db: GetIt.I<SupportPersonsDb>(),
              userId: authenticatedState.userId,
            ),
          ),
          RepositoryProvider<FeatureToggleRepository>(
            create: (_) => FeatureToggleRepository(
              client: GetIt.I<ListenableClient>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              userId: authenticatedState.userId,
            ),
          )
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
                    lastSyncDb: GetIt.I<LastSyncDb>(),
                    clockCubit: context.read<ClockCubit>(),
                    retryDelay: GetIt.I<Delays>().retryDelay,
                    syncDelay: GetIt.I<Delays>().syncDelay,
                  )..add(const SyncAll())),
              lazy: false,
            ),
            BlocProvider<ActivitiesCubit>(
              create: (context) => ActivitiesCubit(
                activityRepository: context.read<ActivityRepository>(),
                syncBloc: context.read<SyncBloc>(),
                analytics: GetIt.I<SeagullAnalytics>(),
              ),
            ),
            BlocProvider<TimerCubit>(
              create: (context) => TimerCubit(
                timerDb: GetIt.I<TimerDb>(),
                analytics: GetIt.I<SeagullAnalytics>(),
              )..loadTimers(),
            ),
            BlocProvider(
              create: (context) => TimerAlarmBloc(
                ticker: GetIt.I<Ticker>(),
                timerCubit: context.read<TimerCubit>(),
              ),
            ),
            BlocProvider<FeatureToggleCubit>(
              lazy: false,
              create: (context) => FeatureToggleCubit(
                featureToggleRepository:
                    context.read<FeatureToggleRepository>(),
              )..updateTogglesFromBackend(),
            ),
            BlocProvider<SupportPersonsCubit>(
              create: (context) => SupportPersonsCubit(
                supportPersonsRepository:
                    context.read<SupportPersonsRepository>(),
              )..loadSupportPersons(),
            ),
            BlocProvider<WeekCalendarCubit>(
              create: (context) => WeekCalendarCubit(
                activitiesCubit: context.read<ActivitiesCubit>(),
                activityRepository: context.read<ActivityRepository>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
                clockCubit: context.read<ClockCubit>(),
              )..goToCurrentWeek(),
            ),
            BlocProvider<UserFileBloc>(
              create: (context) => UserFileBloc(
                userFileRepository: context.read<UserFileRepository>(),
                syncBloc: context.read<SyncBloc>(),
                fileStorage: GetIt.I<FileStorage>(),
              )..add(LoadUserFiles()),
              lazy: false,
            ),
            BlocProvider<SortableBloc>(
              create: (context) =>
                  sortableBloc ??
                  SortableBloc(
                    sortableRepository: context.read<SortableRepository>(),
                    syncBloc: context.read<SyncBloc>(),
                    fileStorageFolder: FileStorage.folder,
                  ),
              lazy: false,
            ),
            BlocProvider<GenericCubit>(
              create: (context) => GenericCubit(
                genericRepository: context.read<GenericRepository>(),
                syncBloc: context.read<SyncBloc>(),
              )..loadGenerics(),
            ),
            BlocProvider<CalendarCubit>(
              create: (context) => CalendarCubit(
                calendarRepository: context.read<CalendarRepository>(),
                userRepository: context.read<UserRepository>(),
              )..loadCalendarId(),
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
                clockCubit: context.read<ClockCubit>(),
              ),
            ),
            BlocProvider<MonthCalendarCubit>(
              create: (context) => MonthCalendarCubit(
                activitiesCubit: context.read<ActivitiesCubit>(),
                activityRepository: context.read<ActivityRepository>(),
                clockCubit: context.read<ClockCubit>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                settingsDb: GetIt.I<SettingsDb>(),
              )..updateMonth(),
            ),
            BlocProvider<DayEventsCubit>(
              create: (context) => DayEventsCubit(
                activitiesCubit: context.read<ActivitiesCubit>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
              )..initialize(),
            ),
            BlocProvider<AlarmCubit>(
              create: (context) => AlarmCubit(
                clockCubit: context.read<ClockCubit>(),
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
                ..checkStatus(allPermissions)
                ..request([Permission.notification]),
            ),
            BlocProvider<DayPartCubit>(
              create: (context) => DayPartCubit(
                context.read<MemoplannerSettingsBloc>(),
                context.read<ClockCubit>(),
              ),
            ),
            BlocProvider<DayCalendarViewCubit>(
              create: (context) => DayCalendarViewCubit(
                GetIt.I<DayCalendarViewDb>(),
                context.read<GenericCubit>(),
              ),
              lazy: false,
            ),
            BlocProvider<TimepillarCubit>(
              create: (context) => TimepillarCubit(
                clockCubit: context.read<ClockCubit>(),
                dayPickerBloc: context.read<DayPickerBloc>(),
                memoSettingsBloc: context.read<MemoplannerSettingsBloc>(),
                dayCalendarViewCubit: context.read<DayCalendarViewCubit>(),
                activitiesCubit: context.read<ActivitiesCubit>(),
                timerAlarmBloc: context.read<TimerAlarmBloc>(),
                dayPartCubit: context.read<DayPartCubit>(),
              )..initialize(),
            ),
            BlocProvider<TimepillarMeasuresCubit>(
              create: (context) => TimepillarMeasuresCubit(
                timepillarCubit: context.read<TimepillarCubit>(),
                dayCalendarViewCubit: context.read<DayCalendarViewCubit>(),
              ),
            ),
            BlocProvider<NightMode>(
              create: (context) => NightMode(
                dayPart: context.read<DayPartCubit>(),
                dayCalendarViewCubit: context.read<DayCalendarViewCubit>(),
                picker: context.read<DayPickerBloc>(),
                timepillarCubit: context.read<TimepillarCubit>(),
              ),
            ),
            BlocProvider<NotificationBloc>(
              create: (context) => NotificationBloc(
                memoplannerSettingBloc: context.read<MemoplannerSettingsBloc>(),
                activityRepository: context.read<ActivityRepository>(),
                settingsDb: GetIt.I<SettingsDb>(),
                timerDb: GetIt.I<TimerDb>(),
                scheduleNotificationsDelay:
                    GetIt.I<Delays>().scheduleNotificationsDelay,
                ticker: GetIt.I<Ticker>(),
                notificationStream: selectNotificationSubject,
              ),
              lazy: false,
            ),
            BlocProvider<SessionsCubit>(
              create: (context) => SessionsCubit(
                sessionsRepository: context.read<SessionsRepository>(),
              )..initialize(),
              lazy: false,
            ),
            BlocProvider<AuthenticatedDialogCubit>(
              create: (context) => AuthenticatedDialogCubit(
                termsOfUseRepository: context.read<TermsOfUseRepository>(),
                permissionCubit: context.read<PermissionCubit>(),
                sortableBloc: context.read<SortableBloc>(),
                newlyLoggedIn: authenticatedState.newlyLoggedIn,
              )..loadTermsOfUse(),
            ),
            if (Config.isMP) ...[
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  battery: GetIt.I<Battery>(),
                  settingsDb: GetIt.I<SettingsDb>(),
                  hasBattery: GetIt.I<Device>().hasBattery,
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
                  clockDelay: GetIt.I<Delays>().inactivityDelay,
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
    super.key,
    this.pushCubit,
  });

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
            app: Config.flavor.id,
            name: Config.flavor.id,
          ),
        ),
        RepositoryProvider<CalendarRepository>(
          create: (context) => CalendarRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            calendarDb: GetIt.I<CalendarDb>(),
          ),
        ),
        if (Config.isMP) ...[
          RepositoryProvider<DeviceRepository>(
            create: (context) => DeviceRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<ListenableClient>(),
              deviceDb: GetIt.I<DeviceDb>(),
            )..fetchDeviceLicense(),
          ),
          RepositoryProvider<VoiceRepository>(
            create: (context) => VoiceRepository(
              client: GetIt.I<ListenableClient>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              applicationSupportDirectory:
                  GetIt.I<Directories>().applicationSupport,
              tempDirectory: GetIt.I<Directories>().temp,
              ttsHandler: GetIt.I<TtsHandler>(),
            ),
          ),
        ],
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PushCubit>(
            create: (context) =>
                pushCubit ??
                PushCubit(backgroundMessageHandler: myBackgroundMessageHandler),
          ),
          BlocProvider<ClockCubit>(
            create: (context) => ClockCubit.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider<ConnectivityCubit>(
            create: (context) => ConnectivityCubit(
              connectivity: GetIt.I<Connectivity>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              myAbiliaConnection: GetIt.I<MyAbiliaConnection>(),
            )..checkConnectivity(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => BaseUrlCubit(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
            ),
          ),
          BlocProvider(
            create: (context) => LocaleCubit(
              settingsDb: GetIt.I<SettingsDb>(),
              seagullAnalytics: GetIt.I<SeagullAnalytics>(),
            ),
          ),
          BlocProvider(
            create: (context) => TouchDetectionCubit(),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => SpeechSettingsCubit(
              voiceDb: GetIt.I<VoiceDb>(),
              acapelaTts: GetIt.I<TtsHandler>(),
            ),
          ),
          if (Config.isMP) ...[
            BlocProvider(
              create: (context) => StartupCubit(
                deviceRepository: context.read<DeviceRepository>(),
                connectivityChanged: context.read<ConnectivityCubit>().stream,
              ),
            ),
            BlocProvider<VoicesCubit>(
              create: (context) => VoicesCubit(
                speechSettingsCubit: context.read<SpeechSettingsCubit>(),
                voiceRepository: context.read<VoiceRepository>(),
                localeChangeStream: context.read<LocaleCubit>().stream,
                languageCode: context.read<LocaleCubit>().state.languageCode,
              )..initialize(),
              lazy: false,
            ),
          ],
        ],
        child: child,
      ),
    );
  }
}

class AuthenticationBlocProvider extends StatelessWidget {
  const AuthenticationBlocProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(
            userRepository: context.read<UserRepository>(),
            onLogout: () async => Future.wait<void>(
              [
                DatabaseRepository.clearAll(GetIt.I<Database>()),
                GetIt.I<SeagullLogger>().uploadLogsToBackend(),
                clearNotificationSubject(),
                notificationPlugin.cancelAll(),
                GetIt.I<FileStorage>().deleteUserFolder(),
                _clearSettings(),
              ],
            ),
            client: GetIt.I<ListenableClient>(),
          )..add(CheckAuthentication()),
        ),
        BlocProvider<LicenseCubit>(
          create: (context) => LicenseCubit(
            clockCubit: context.read<ClockCubit>(),
            pushCubit: context.read<PushCubit>(),
            userRepository: context.read<UserRepository>(),
            authenticationBloc: context.read<AuthenticationBloc>(),
            product: Product.memoplanner,
          )..reloadLicenses(),
        ),
      ],
      child: child,
    );
  }

  Future<void> _clearSettings() async {
    const deviceRecords = DeviceDb.records;
    const voiceRecords = VoiceDb.storeOnLogoutRecords;
    const baseUrlRecord = BaseUrlDb.baseUrlRecord;
    const records = {...deviceRecords, ...voiceRecords, baseUrlRecord};

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => !records.contains(key));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
