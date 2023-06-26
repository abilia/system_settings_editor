import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ui/buttons/link_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.unauthenticatedState, super.key});

  final Unauthenticated unauthenticatedState;

  @override
  Widget build(BuildContext context) {
    final reason = unauthenticatedState.loggedOutReason;
    final translate = Lt.of(context);
    if (reason != LoggedOutReason.logOut) {
      Future(
        () async => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(translate.unauthorized),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(translate.loggedOut),
                  ],
                ),
              ),
              actions: <Widget>[
                LinkButton(
                  title: translate.ok,
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ],
            );
          },
        ),
      );
    }
    return BlocProvider(
      create: (context) => LoginCubit(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        pushService: GetIt.I<FirebasePushService>(),
        clockBloc: context.read<ClockBloc>(),
        userRepository: context.read<UserRepository>(),
        database: GetIt.I<Database>(),
        allowExpiredLicense: false,
        licenseType: LicenseType.handi,
      ),
      child: Scaffold(
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.cause.name),
                ),
              );
            }
          },
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translate.userName),
                      Tooltip(
                        message: translate.userName,
                        child: TextField(
                          onChanged: context.read<LoginCubit>().usernameChanged,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translate.password),
                      Tooltip(
                        message: translate.password,
                        child: TextField(
                          onChanged: context.read<LoginCubit>().passwordChanged,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...backendEnvironments.entries.map(
                        (kvp) => Builder(
                          builder: (context) => RadioMenuButton(
                            value: kvp.key,
                            onChanged: (s) async => context
                                .read<BaseUrlCubit>()
                                .updateBaseUrl(kvp.key),
                            groupValue: context.watch<BaseUrlCubit>().state,
                            child: Text(kvp.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                  LinkButton(
                    onPressed: state.isFormValid
                        ? context.read<LoginCubit>().loginButtonPressed
                        : null,
                    title: (translate.signIn),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
