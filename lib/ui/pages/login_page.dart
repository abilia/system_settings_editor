import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

class LoginPage extends StatelessWidget {
  final Unauthenticated authState;

  const LoginPage({
    Key key,
    @required this.authState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (authState?.loggedOutReason == LoggedOutReason.LICENSE_EXPIRED) {
      Future.delayed(
        Duration.zero,
        () => showViewDialog(
          context: context,
          builder: (_) => LicenseExpiredDialog(),
          wrapWithAuthProviders: false,
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            pushService: GetIt.I<FirebasePushService>(),
            clockBloc: BlocProvider.of<ClockBloc>(context),
          ),
        ),
        BlocProvider<LoginFormBloc>(create: (context) => LoginFormBloc()),
      ],
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (_, state) =>
            state is LoginFailure &&
            state.loginFailureCause == LoginFailureCause.License,
        listener: (context, state) async {
          context.read<LoginFormBloc>().add(ResetForm());
          await showViewDialog(
            context: context,
            builder: (_) => LicenseExpiredDialog(),
            wrapWithAuthProviders: false,
          );
        },
        child: Scaffold(
          body: SafeArea(
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}
