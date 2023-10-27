import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/listeners/authenticated_listener.dart';
import 'package:handi/providers.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqflite.dart';

class TopLevelListener extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const TopLevelListener({
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AuthenticationListener(
      navigatorKey: navigatorKey,
      onAuthenticated: (context, navigator, state) async {
        await Permission.notification.request();
        await navigator.pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (_) => AuthenticatedProviders(
              userId: state.userId,
              child: AuthenticatedListener(
                child: LoggedInPage(
                  authenticated: state,
                ),
              ),
            ),
            settings: (LoggedInPage).routeSetting(),
          ),
          (_) => false,
        );
      },
      onUnauthenticated: (context, navigator, authenticationState) async {
        await navigator.pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (context) => LoginCubit(
                authenticationBloc:
                    BlocProvider.of<AuthenticationBloc>(context),
                pushService: GetIt.I<FirebasePushService>(),
                clockCubit: context.read<ClockCubit>(),
                userRepository: context.read<UserRepository>(),
                database: GetIt.I<Database>(),
                allowExpiredLicense: false,
                product: Product.handicalendar,
              ),
              child: const LoginPage(),
            ),
            settings: (LoginPage).routeSetting(
              properties: {
                'logout reason': authenticationState.loggedOutReason.name,
              },
            ),
          ),
          (_) => false,
        );
      },
      child: child,
    );
  }
}
