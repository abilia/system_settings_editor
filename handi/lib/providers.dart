import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:calendar_repository/calendar_db.dart';
import 'package:calendar_repository/calendar_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/bloc/base_url_cubit.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/clock_bloc.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:handi/main.dart';

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
              calendarRepository: context.read<CalendarRepository>(),
            )..add(CheckAuthentication()),
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
