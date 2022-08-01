import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class LoginPage extends StatelessWidget {
  final Unauthenticated authState;

  const LoginPage({
    Key? key,
    required this.authState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    if (authState.loggedOutReason == LoggedOutReason.licenseExpired) {
      Future.delayed(
        Duration.zero,
        () => showViewDialog(
          context: context,
          builder: (_) => LicenseErrorDialog(
            heading: translate.licenseExpired,
            message: translate.licenseExpiredMessage,
          ),
          wrapWithAuthProviders: false,
        ),
      );
    }
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        pushService: GetIt.I<FirebasePushService>(),
        clockBloc: BlocProvider.of<ClockBloc>(context),
        userRepository: context.read<UserRepository>(),
      ),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (_, state) => state is LoginFailure,
        listener: (context, state) async {
          if (state is LoginFailure) {
            final cause = state.cause;
            if (state.licenseError) {
              context.read<LoginCubit>().clearFailure();
              await showViewDialog(
                context: context,
                builder: (_) => LicenseErrorDialog(
                  heading: cause.heading(translate),
                  message: cause.message(translate),
                ),
                wrapWithAuthProviders: false,
              );
            } else {
              await showViewDialog(
                context: context,
                builder: (_) => ErrorDialog(
                  text: cause.message(translate),
                ),
                wrapWithAuthProviders: false,
              );
            }
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: SafeArea(
              child: LoginForm(
                  message:
                      authState.loggedOutReason == LoggedOutReason.deautorized
                          ? translate.loggedOutMessage
                          : ''),
            ),
            resizeToAvoidBottomInset: false,
          ),
        ),
      ),
    );
  }
}
