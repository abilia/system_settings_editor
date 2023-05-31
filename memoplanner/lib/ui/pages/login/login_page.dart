import 'package:auth/auth.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatelessWidget {
  final Unauthenticated unauthenticatedState;

  const LoginPage({
    required this.unauthenticatedState,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final reason = unauthenticatedState.loggedOutReason;
    if (reason != LoggedOutReason.logOut) {
      Future.delayed(
        Duration.zero,
        () async => showViewDialog(
          context: context,
          builder: (_) => LicenseErrorDialog(
            heading: reason.header(translate),
            message: reason.message(translate),
          ),
          wrapWithAuthProviders: false,
          routeSettings: (LicenseErrorDialog)
              .routeSetting(properties: {'reason': reason.name}),
        ),
      );
    }
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        pushService: GetIt.I<FirebasePushService>(),
        clockBloc: BlocProvider.of<ClockBloc>(context),
        userRepository: context.read<UserRepository>(),
        database: GetIt.I<Database>(),
        allowExpiredLicense: Config.isMP,
        licenseType: LicenseType.memoplanner,
      ),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (_, state) => state is LoginFailure,
        listener: (context, state) async {
          if (state is LoginFailure) {
            final cause = state.cause;
            if (state.noLicense || state.licenseExpired && Config.isMPGO) {
              context.read<LoginCubit>().clearFailure();
              await showViewDialog(
                context: context,
                builder: (_) => LicenseErrorDialog(
                  heading: cause.heading(translate),
                  message: cause.message(translate),
                ),
                wrapWithAuthProviders: false,
                routeSettings: (LicenseErrorDialog).routeSetting(
                  properties: {'reason': cause.name},
                ),
              );
            } else if (state.licenseExpired && Config.isMP) {
              final loginCubit = context.read<LoginCubit>();
              final licenseExpiredConfirmed = await showViewDialog(
                context: context,
                builder: (context) => ConfirmWarningDialog(
                  text: Translator.of(context).translate.licenseExpiredMessage,
                ),
                routeSettings: (ConfirmWarningDialog).routeSetting(
                  properties: {'reason': 'License Expired'},
                ),
              );
              if (licenseExpiredConfirmed) {
                await loginCubit.licenseExpiredWarningConfirmed();
              }
            } else {
              await showViewDialog(
                context: context,
                builder: (_) => ErrorDialog(
                  text: cause.message(translate),
                ),
                wrapWithAuthProviders: false,
                routeSettings: (ErrorDialog)
                    .routeSetting(properties: {'reason': cause.name}),
              );
            }
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: SafeArea(
              child: LoginForm(
                  message: unauthenticatedState.loggedOutReason ==
                          LoggedOutReason.unauthorized
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
