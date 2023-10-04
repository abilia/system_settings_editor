import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/widgets/open_settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.unauthenticatedState, super.key});

  final Unauthenticated unauthenticatedState;

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final reason = unauthenticatedState.loggedOutReason;
    if (reason != LoggedOutReason.logOut) _showLoggedOutAlert(context);
    return BlocProvider(
      create: (context) => LoginCubit(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        pushService: GetIt.I<FirebasePushService>(),
        clockCubit: context.read<ClockCubit>(),
        userRepository: context.read<UserRepository>(),
        database: GetIt.I<Database>(),
        allowExpiredLicense: false,
        product: Product.carybase,
      ),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.cause.name),
                  ),
                );
              }
            },
            child: BlocSelector<LoginCubit, LoginState, bool>(
              selector: (state) => state.isFormValid,
              builder: (context, isFormValid) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const LogoWithChangeServer(),
                    const SizedBox(height: 24),
                    const Text('Connect to myAbilia'),
                    const SizedBox(height: 8),
                    const Text(
                      'Make sure that CARY Base is connected to myAbilia.'
                      ' Log in here with the same account.',
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate.username_email),
                        Tooltip(
                          message: translate.username_email,
                          child: TextField(
                            onChanged:
                                context.read<LoginCubit>().usernameChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Password'),
                        Tooltip(
                          message: 'Password',
                          child: TextField(
                            onChanged:
                                context.read<LoginCubit>().passwordChanged,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: isFormValid
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
      ),
    );
  }

  void _showLoggedOutAlert(BuildContext context) {
    Future(
      () async => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Unauthorized'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Logged out'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LogoWithChangeServer extends StatelessWidget {
  const LogoWithChangeServer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.asset('assets/graphics/cary_login.png'),
      onLongPress: () async => showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: [
            ...backendEnvironments.entries.map(
              (kvp) => Builder(
                builder: (context) => RadioMenuButton(
                  value: kvp.key,
                  onChanged: (s) async =>
                      context.read<BaseUrlCubit>().updateBaseUrl(kvp.key),
                  groupValue: context.watch<BaseUrlCubit>().state,
                  child: Text(kvp.value),
                ),
              ),
            ),
            const OpenSettingsButton()
          ],
        ),
      ),
    );
  }
}
