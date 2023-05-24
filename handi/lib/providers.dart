import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:calendar/all.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/background/background.dart';
import 'package:handi/bloc/sync/sync_bloc.dart';
import 'package:handi/main.dart';
import 'package:handi/models/sync_delays.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/clock_bloc.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:sqflite/sqlite_api.dart';

class AuthenticatedBlocsProvider extends StatelessWidget {
  final Authenticated authenticatedState;
  final Widget child;
  final SyncBloc? syncBloc;

  const AuthenticatedBlocsProvider({
    required this.authenticatedState,
    required this.child,
    this.syncBloc,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<SyncBloc>(
            create: (context) =>
                syncBloc ??
                (SyncBloc(
                  pushCubit: context.read<PushCubit>(),
                  clockBloc: context.read<ClockBloc>(),
                  syncDelay: GetIt.I<SyncDelays>(),
                )..add(const SyncAll())),
            lazy: false,
          ),
        ],
        child: child,
      );
}

class Providers extends StatelessWidget {
  final Widget child;

  const Providers({required this.child, super.key});

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
          BlocProvider(
            create: (context) => AuthenticationBloc(
              userRepository: UserRepository(
                baseUrlDb: GetIt.I<BaseUrlDb>(),
                client: GetIt.I<ListenableClient>(),
                loginDb: GetIt.I<LoginDb>(),
                userDb: GetIt.I<UserDb>(),
                licenseDb: GetIt.I<LicenseDb>(),
                deviceDb: GetIt.I<DeviceDb>(),
                app: appName,
                name: appName,
              ),
            )..add(CheckAuthentication()),
          ),
          BlocProvider<PushCubit>(
            create: (context) =>
                PushCubit(backgroundMessageHandler: myBackgroundMessageHandler),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider(
            create: (context) => LoginCubit(
              authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
              pushService: GetIt.I<FirebasePushService>(),
              clockBloc: context.read<ClockBloc>(),
              userRepository: context.read<UserRepository>(),
              database: GetIt.I<Database>(),
              allowExiredLicense: false,
              licenseType: LicenseType.handi,
            ),
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
