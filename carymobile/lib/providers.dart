// ignore_for_file: discarded_futures

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:calendar/all.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/background/background.dart';
import 'package:carymessenger/background/notification.dart';
import 'package:carymessenger/bloc/next_alarm_scheduler_bloc.dart';
import 'package:carymessenger/cubit/alarm_cubit.dart';
import 'package:carymessenger/cubit/production_guide_cubit.dart';
import 'package:carymessenger/main.dart';
import 'package:carymessenger/models/delays.dart';
import 'package:connectivity/connectivity_cubit.dart';
import 'package:connectivity/myabilia_connection.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';
import 'package:get_it/get_it.dart';
import 'package:permissions/permission_cubit.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortables/sortables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:user_files/user_files.dart';

class TopLevelProviders extends StatelessWidget {
  final Widget child;

  const TopLevelProviders({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => CalendarRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            calendarDb: GetIt.I<CalendarDb>(),
            client: GetIt.I<ListenableClient>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => UserRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            loginDb: GetIt.I<LoginDb>(),
            userDb: GetIt.I<UserDb>(),
            licenseDb: GetIt.I<LicenseDb>(),
            deviceDb: GetIt.I<DeviceDb>(),
            app: appName,
            name: appName,
          ),
        ),
        RepositoryProvider(
          create: (context) => VoiceRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            ttsHandler: GetIt.I<TtsHandler>(),
            client: GetIt.I<ListenableClient>(),
            tempDirectory: GetIt.I<Directories>().temp,
            applicationSupportDirectory:
                GetIt.I<Directories>().applicationSupport,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => PushCubit(
              backgroundMessageHandler: firebaseBackgroundMessageHandler,
            ),
          ),
          BlocProvider(
            create: (context) => ClockCubit.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider(
            create: (context) => BaseUrlCubit(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
            ),
          ),
          BlocProvider<PermissionCubit>(
            create: (context) => PermissionCubit()
              ..checkStatus([Permission.ignoreBatteryOptimizations]),
            lazy: false,
          ),
          BlocProvider<ConnectivityCubit>(
            create: (context) => ConnectivityCubit(
              connectivity: GetIt.I<Connectivity>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              myAbiliaConnection: GetIt.I<MyAbiliaConnection>(),
            )..checkConnectivity(),
            lazy: false,
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => SpeechSettingsCubit(
              voiceDb: GetIt.I<VoiceDb>(),
              acapelaTts: GetIt.I<TtsHandler>(),
            ),
          ),
          BlocProvider<VoicesCubit>(
            create: (context) => VoicesCubit(
              speechSettingsCubit: context.read<SpeechSettingsCubit>(),
              voiceRepository: context.read<VoiceRepository>(),
              languageCode: 'sv',
              localeChangeStream: const Stream.empty(),
            )..initialize(),
          ),
          BlocProvider<ProductionGuideCubit>(
            create: (context) => ProductionGuideCubit(
              speechSettingsCubit: context.read<SpeechSettingsCubit>(),
              permissionCubit: context.read<PermissionCubit>(),
            ),
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
        BlocProvider(
          create: (context) => AuthenticationBloc(
            userRepository: context.read<UserRepository>(),
            client: GetIt.I<ListenableClient>(),
            onLogout: () async => Future.wait<void>(
              [
                DatabaseRepository.clearAll(GetIt.I<Database>()),
                GetIt.I<FileStorage>().deleteUserFolder(),
                _clearSettings(),
              ],
            ),
          )..add(CheckAuthentication()),
        ),
        BlocProvider(
          create: (context) => LicenseCubit(
            clockCubit: context.read<ClockCubit>(),
            pushCubit: context.read<PushCubit>(),
            userRepository: context.read<UserRepository>(),
            authenticationBloc: context.read<AuthenticationBloc>(),
            product: Product.carybase,
          )..reloadLicenses(),
        ),
      ],
      child: child,
    );
  }

  Future<void> _clearSettings() async {
    const deviceRecords = DeviceDb.records;
    const baseUrlRecord = BaseUrlDb.baseUrlRecord;
    const records = {...deviceRecords, baseUrlRecord};

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => !records.contains(key));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

class AuthenticatedProviders extends StatelessWidget {
  final int userId;
  final Widget child;

  const AuthenticatedProviders({
    required this.userId,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => ActivityRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            activityDb: GetIt.I<ActivityDb>(),
            userId: userId,
          ),
        ),
        RepositoryProvider(
          create: (context) => UserFileRepository(
            client: GetIt.I<ListenableClient>(),
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            userFileDb: GetIt.I<UserFileDb>(),
            fileStorage: GetIt.I<FileStorage>(),
            loginDb: GetIt.I<LoginDb>(),
            userId: userId,
            multipartRequestBuilder: GetIt.I<MultipartRequestBuilder>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => SortableRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            sortableDb: GetIt.I<SortableDb>(),
            userId: userId,
          ),
        ),
        RepositoryProvider(
          create: (context) => GenericRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            genericDb: GetIt.I<GenericDb>(),
            userId: userId,
            noSyncSettings: const {},
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => SyncBloc(
              pushCubit: context.read<PushCubit>(),
              licenseCubit: context.read<LicenseCubit>(),
              activityRepository: context.read<ActivityRepository>(),
              userFileRepository: context.read<UserFileRepository>(),
              sortableRepository: context.read<SortableRepository>(),
              genericRepository: context.read<GenericRepository>(),
              lastSyncDb: GetIt.I<LastSyncDb>(),
              clockCubit: context.read<ClockCubit>(),
              syncDelay: GetIt.I<Delays>().syncDelay,
              retryDelay: GetIt.I<Delays>().retryDelay,
            )..add(const SyncAll()),
          ),
          BlocProvider(
            create: (context) => ActivitiesCubit(
              activityRepository: context.read<ActivityRepository>(),
              syncBloc: context.read<SyncBloc>(),
              analytics: SeagullAnalytics.empty(),
            ),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => UserFileBloc(
              userFileRepository: context.read<UserFileRepository>(),
              syncBloc: context.read<SyncBloc>(),
              fileStorage: GetIt.I<FileStorage>(),
            )..add(LoadUserFiles()),
          ),
          BlocProvider(
            create: (context) => SortableBloc(
              sortableRepository: context.read<SortableRepository>(),
              syncBloc: context.read<SyncBloc>(),
              fileStorageFolder: FileStorage.folder,
            ),
          ),
          BlocProvider(
            create: (context) => GenericCubit(
              genericRepository: context.read<GenericRepository>(),
              syncBloc: context.read<SyncBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => AlarmCubit(
              clockCubit: context.read<ClockCubit>(),
              activityRepository: context.read<ActivityRepository>(),
              checkAlarmStream: notificationStream,
            ),
          ),
          BlocProvider<NextAlarmSchedulerBloc>(
            create: (context) => NextAlarmSchedulerBloc(
              activityRepository: context.read<ActivityRepository>(),
              ticker: GetIt.I<Ticker>(),
              scheduleNotificationsDelay:
                  GetIt.I<Delays>().scheduleNotificationsDelay,
              rescheduleStreams: [
                context.read<ActivitiesCubit>().stream,
                notificationStream,
              ],
            )..add(const ScheduleNextAlarm('On create')),
          ),
        ],
        child: child,
      ),
    );
  }
}