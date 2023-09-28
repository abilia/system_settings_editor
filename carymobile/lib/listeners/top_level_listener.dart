import 'package:auth/listeners/authentication_listener.dart';
import 'package:carymessenger/listeners/authenticated_listener.dart';
import 'package:carymessenger/providers.dart';
import 'package:carymessenger/ui/pages/login_page.dart';
import 'package:carymessenger/ui/pages/main/main_page.dart';
import 'package:flutter/material.dart';
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
            builder: (_) => AuthenticatedProviders(
              userId: state.userId,
              child: AuthenticatedListener(
                child: MainPage(
                  authenticated: state,
                ),
              ),
            ),
            settings: (MainPage).routeSetting(),
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
