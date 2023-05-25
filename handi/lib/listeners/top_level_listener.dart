import 'package:auth/bloc/push/push_cubit.dart';
import 'package:auth/listeners/authentication_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/background/background.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login_page.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

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
      onAuthenticated: (navigator, state) async {
        await navigator.pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider<PushCubit>(
              create: (context) => PushCubit(
                  backgroundMessageHandler: myBackgroundMessageHandler),
              lazy: false,
              child: LoggedInPage(
                authenticated: state,
              ),
            ),
            settings: (LoggedInPage).routeSetting(),
          ),
          (_) => false,
        );
      },
      onUnauthenticated: (context, navigator, state) async {
        await navigator.pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (_) => const LoginPage(),
            settings: (LoginPage).routeSetting(
              properties: {
                'logout reason': state.loggedOutReason.name,
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
