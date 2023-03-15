import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef OnAuthenticated = void Function(
  NavigatorState navigator,
  Authenticated state,
);
typedef OnUnauthenticated = void Function(
  BuildContext context,
  NavigatorState navigator,
  Unauthenticated state,
);

class AuthenticationListener
    extends BlocListener<AuthenticationBloc, AuthenticationState> {
  final OnAuthenticated onAuthenticated;
  final OnUnauthenticated onUnauthenticated;
  final GlobalKey<NavigatorState> navigatorKey;

  AuthenticationListener({
    required this.onAuthenticated,
    required this.onUnauthenticated,
    required this.navigatorKey,
    super.child,
    Key? key,
  }) : super(
          key: key,
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
              onAuthenticated(navigator, state);
            } else if (state is Unauthenticated) {
              onUnauthenticated(context, navigator, state);
            }
          },
        );
}
