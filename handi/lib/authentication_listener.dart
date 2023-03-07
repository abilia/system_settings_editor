import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login_page.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class AuthenticationListener extends StatelessWidget {
  const AuthenticationListener({
    required this.child,
    required this.navigatorKey,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          previous.forcedNewState != current.forcedNewState,
      listener: (context, state) async {
        final navigator = navigatorKey.currentState;
        if (navigator == null) {
          context.read<AuthenticationBloc>().add(NotReady());
          return;
        }
        if (state is Authenticated) {
          await navigator.pushAndRemoveUntil<void>(
            MaterialPageRoute<void>(
              builder: (_) => LoggedInPage(authenticated: state),
              settings: (LoggedInPage).routeSetting(),
            ),
            (_) => false,
          );
        } else if (state is Unauthenticated) {
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
        }
      },
      child: child,
    );
  }
}
