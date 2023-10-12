import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/themes/colors.dart';
import 'package:carymessenger/ui/themes/text_styles.dart';
import 'package:carymessenger/ui/widgets/buttons/android_settings_button.dart';
import 'package:carymessenger/ui/widgets/version_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqflite.dart';

part 'login_error_listener.dart';

part 'logo_with_change_server.dart';

part 'password_input_field.dart';

part 'username_input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.unauthenticatedState, super.key});

  final Unauthenticated unauthenticatedState;

  @override
  Widget build(BuildContext context) {
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
          child: LoginErrorListener(
            child: BlocSelector<LoginCubit, LoginState, bool>(
              selector: (state) => state.isFormValid,
              builder: (context, isFormValid) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                      bottom: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LogoWithChangeServer(),
                        SizedBox(height: 24),
                        Text(
                          'Connect to myAbilia',
                          style: headline4,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Make sure that CARY Base is connected to myAbilia.'
                          ' Log in here with the same account.',
                          style: body,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        UsernameInputField(),
                        SizedBox(height: 12),
                        PasswordInputField(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ActionButtonGreen(
                      onPressed: isFormValid
                          ? context.read<LoginCubit>().loginButtonPressed
                          : null,
                      leading: const Icon(AbiliaIcons.ok),
                      text: 'Log in',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
