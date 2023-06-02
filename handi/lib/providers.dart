// ignore_for_file: discarded_futures

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:calendar/all.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/background/background.dart';
import 'package:handi/main.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/clock_bloc.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:sortables/sortables.dart';
import 'package:sqflite/sqflite.dart';
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
        RepositoryProvider<UserRepository>(
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PushCubit>(
            lazy: false,
            create: (context) => PushCubit(
              backgroundMessageHandler: myBackgroundMessageHandler,
            ),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider(
            create: (context) => BaseUrlCubit(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
            ),
          )
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
            userRepository: context.read<UserRepository>(),
            client: GetIt.I<ListenableClient>(),
            onLogout: () async => Future.wait<void>(
              [
                DatabaseRepository.clearAll(GetIt.I<Database>()),
                GetIt.I<FileStorage>().deleteUserFolder(),
              ],
            ),
          )..add(CheckAuthentication()),
        ),
        BlocProvider<LicenseCubit>(
          create: (context) => LicenseCubit(
            clockBloc: context.read<ClockBloc>(),
            pushCubit: context.read<PushCubit>(),
            userRepository: context.read<UserRepository>(),
            authenticationBloc: context.read<AuthenticationBloc>(),
            licenseType: LicenseType.handi,
          )..reloadLicenses(),
        ),
      ],
      child: child,
    );
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
        RepositoryProvider<ActivityRepository>(
          create: (context) => ActivityRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            activityDb: GetIt.I<ActivityDb>(),
            userId: userId,
          ),
        ),
        RepositoryProvider<UserFileRepository>(
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
        RepositoryProvider<SortableRepository>(
          create: (context) => SortableRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            sortableDb: GetIt.I<SortableDb>(),
            userId: userId,
          ),
        ),
        RepositoryProvider<GenericRepository>(
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
          BlocProvider<SyncBloc>(
            lazy: false,
            create: (context) => SyncBloc(
              pushCubit: context.read<PushCubit>(),
              licenseCubit: context.read<LicenseCubit>(),
              activityRepository: context.read<ActivityRepository>(),
              userFileRepository: context.read<UserFileRepository>(),
              sortableRepository: context.read<SortableRepository>(),
              genericRepository: context.read<GenericRepository>(),
              lastSyncDb: GetIt.I<LastSyncDb>(),
              clockBloc: context.read<ClockBloc>(),
              syncDelay: GetIt.I<SyncDelays>(),
            )..add(const SyncAll()),
          ),
          BlocProvider(
            create: (context) => ActivitiesBloc(
              activityRepository: context.read<ActivityRepository>(),
              syncBloc: context.read<SyncBloc>(),
            ),
          ),
          BlocProvider<UserFileBloc>(
            create: (context) => UserFileBloc(
              userFileRepository: context.read<UserFileRepository>(),
              syncBloc: context.read<SyncBloc>(),
              fileStorage: GetIt.I<FileStorage>(),
            ),
          ),
          BlocProvider<SortableBloc>(
            create: (context) => SortableBloc(
              sortableRepository: context.read<SortableRepository>(),
              syncBloc: context.read<SyncBloc>(),
              fileStorageFolder: FileStorage.folder,
            ),
          ),
          BlocProvider<GenericCubit>(
            create: (context) => GenericCubit(
              genericRepository: context.read<GenericRepository>(),
              syncBloc: context.read<SyncBloc>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
