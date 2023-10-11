import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ui/components/action_button/action_button.dart';
import 'package:ui/components/combobox/combobox.dart';
import 'package:ui/tokens/numericals.dart';

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
              title: const Text('Unauthorized'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Logged out'),
                  ],
                ),
              ),
              actions: <Widget>[
                ActionButtonPrimary(
                  text: 'Ok',
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
        clockCubit: context.read<ClockCubit>(),
        userRepository: context.read<UserRepository>(),
        database: GetIt.I<Database>(),
        allowExpiredLicense: false,
        product: Product.handicalendar,
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
            builder: (context, state) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(numerical600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Tooltip(
                      message: 'Username',
                      child: Combobox(
                        label: 'Username',
                        onChanged: context.read<LoginCubit>().usernameChanged,
                      ),
                    ),
                    Tooltip(
                      message: 'Password',
                      child: Combobox(
                        label: 'Password',
                        onChanged: context.read<LoginCubit>().passwordChanged,
                      ),
                    ),
                    const SizedBox(height: numerical600),
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
                    const Spacer(),
                    ActionButtonPrimary(
                      text: translate.signIn,
                      onPressed: state.isFormValid
                          ? context.read<LoginCubit>().loginButtonPressed
                          : null,
                      leadingIcon: MdiIcons.login,
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
}
