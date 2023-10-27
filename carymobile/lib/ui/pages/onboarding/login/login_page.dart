import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/themes/colors.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:carymessenger/ui/widgets/support_id_text.dart';
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
    final translate = Lt.of(context);
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
      child: BlocSelector<LoginCubit, LoginState, bool>(
        selector: (state) => state.isFormValid,
        builder: (context, isFormValid) => SafeArea(
          child: Stack(
            children: [
              Scaffold(
                body: LoginErrorListener(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      height: constraints.maxHeight,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 24,
                            left: 16,
                            right: 16,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const LogoWithChangeServer(),
                              const SizedBox(height: 24),
                              Text(
                                translate.connect_to_myabilia,
                                style: headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                translate.login_hint,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              const UsernameInputField(),
                              const SizedBox(height: 12),
                              const PasswordInputField(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ActionButtonGreen(
                    onPressed: isFormValid
                        ? context.read<LoginCubit>().loginButtonPressed
                        : null,
                    leading: const Icon(AbiliaIcons.ok),
                    text: translate.log_in,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}