import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;
  final FirebasePushService push;

  const LoginPage({Key key, @required this.userRepository, @required this.push})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            pushService: push,
            clockBloc: BlocProvider.of<ClockBloc>(context),
          ),
        ),
        BlocProvider<LoginFormBloc>(create: (context) => LoginFormBloc()),
      ],
      child: Scaffold(
        body: SafeArea(
            child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is Unauthenticated &&
                state.loggedOutReason == LoggedOutReason.LICENSE_EXPIRED) {
              Future.delayed(
                Duration.zero,
                () => showViewDialog(
                  context: context,
                  builder: (context) {
                    return LicenseExpiredDialog();
                  },
                ),
              );
            }
            return LoginForm();
          },
        )),
      ),
    );
  }
}
