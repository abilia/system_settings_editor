import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/components/combo_box.dart';
import 'package:ui/states.dart';
import 'package:ui/themes/abilia_theme.dart';

part 'logo_with_change_server.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.unauthenticatedState,
    super.key,
  });

  final Unauthenticated unauthenticatedState;

  @override
  Widget build(BuildContext context) {
    final reason = unauthenticatedState.loggedOutReason;
    final translate = Lt.of(context);
    final abiliaTheme = AbiliaTheme.of(context);
    final textStyles = abiliaTheme.textStyles;
    final spacings = abiliaTheme.spacings;
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
                SeagullActionButton(
                  text: 'Ok',
                  type: ActionButtonType.primary,
                  size: ButtonSize.large,
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
        body: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) => SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacings.spacing400,
                vertical: spacings.spacing600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LogoWithChangeServer(),
                  SizedBox(height: spacings.spacing800),
                  Text(
                    'Welcome to Handi!',
                    style: textStyles.primary525,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacings.spacing800),
                  Tooltip(
                    message: 'Username',
                    child: SeagullComboBox(
                      label: 'Username',
                      leadingIcon: Symbols.account_circle,
                      textInputAction: TextInputAction.next,
                      onChanged: context.read<LoginCubit>().usernameChanged,
                      messageState:
                          state is LoginFailure ? MessageState.error : null,
                    ),
                  ),
                  SizedBox(height: spacings.spacing300),
                  Tooltip(
                    message: 'Password',
                    child: SeagullComboBox(
                      label: 'Password',
                      leadingIcon: Symbols.key,
                      trailingIcon: Symbols.visibility,
                      obscureText: true,
                      onChanged: context.read<LoginCubit>().passwordChanged,
                      messageState:
                          state is LoginFailure ? MessageState.error : null,
                      message: state is LoginFailure ? state.cause.name : null,
                    ),
                  ),
                  SizedBox(height: spacings.spacing600),
                  SeagullActionButton(
                    text: translate.signIn,
                    type: ActionButtonType.primary,
                    size: ButtonSize.large,
                    isLoading: state is LoginLoading,
                    leadingIcon: MdiIcons.login,
                    onPressed: state.isFormValid
                        ? context.read<LoginCubit>().loginButtonPressed
                        : null,
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
