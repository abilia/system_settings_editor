import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class LoginPage extends StatelessWidget {
  final Unauthenticated authState;

  const LoginPage({
    Key key,
    @required this.authState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    if (authState?.loggedOutReason == LoggedOutReason.LICENSE_EXPIRED) {
      Future.delayed(
        Duration.zero,
        () => showViewDialog(
          context: context,
          builder: (_) => LicenseErrorDialog(
            message: translate.licenseExpiredMessage,
          ),
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
        listenWhen: (_, state) => state is LoginFailure && (state.licenseError),
        listener: (context, state) async {
          final cause = (state as LoginFailure).loginFailureCause;
          context.read<LoginFormBloc>().add(ResetForm());
          await showViewDialog(
            context: context,
            builder: (_) => LicenseErrorDialog(
              heading: cause.heading(translate),
              message: cause.message(translate),
            ),
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
