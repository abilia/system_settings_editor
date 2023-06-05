import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_bloc.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.unauthenticatedState, super.key});

  final Unauthenticated unauthenticatedState;

  @override
  Widget build(BuildContext context) {
    final reason = unauthenticatedState.loggedOutReason;
    if (reason != LoggedOutReason.logOut) {
      Future.delayed(
        Duration.zero,
        () async => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Unauthorized dialogue'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('You have been logged out.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Approve'),
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
                      const Text('Username'),
                      Tooltip(
                        message: 'Username',
                        child: TextField(
                          onChanged: context.read<LoginCubit>().usernameChanged,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password'),
                      Tooltip(
                        message: 'Password',
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
                  OutlinedButton(
                    onPressed: state.isFormValid
                        ? context.read<LoginCubit>().loginButtonPressed
                        : null,
                    child: const Text('Sign in'),
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
