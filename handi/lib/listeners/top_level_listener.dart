import 'package:auth/listeners/authentication_listener.dart';
import 'package:flutter/material.dart';
import 'package:handi/listeners/authenticated_listener.dart';
import 'package:handi/providers.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
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
            builder: (_) =>
                LoginPage(unauthenticatedState: authenticationState),
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
