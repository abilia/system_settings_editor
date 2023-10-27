import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:repository_base/end_point.dart';
import 'package:text_to_speech/tts_handler.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/components/combo_box.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/utils/states.dart';

part 'login_button.dart';

part 'login_inputs.dart';

part 'logo_with_change_server.dart';

part 'welcome_to_handi_text.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    final spacings = abiliaTheme.spacings;
    final loginFailureCause = context.select((LoginCubit cubit) {
      final state = cubit.state;
      return state is LoginFailure ? state.cause : null;
    });

    final helperBoxIcon = _getHelperBoxIcon(loginFailureCause);
    final helperBoxMessage = _getHelperBoxMessage(context, loginFailureCause);
    final messageState = _getMessageState(loginFailureCause);
    return Scaffold(
      backgroundColor: abiliaTheme.colors.surface.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacings.spacing400,
              vertical: spacings.spacing600,
            ),
            child: Column(
              children: [
                const LogoWithChangeServer(),
                SizedBox(height: spacings.spacing800),
                const _WelcomeToHandiText(),
                SizedBox(height: spacings.spacing800),
                _UsernameLoginInput(
                  messageState: messageState,
                ),
                SizedBox(height: spacings.spacing300),
                _PasswordLoginInput(
                  messageState: messageState,
                  helperBoxIcon: helperBoxIcon,
                  helperBoxMessage: helperBoxMessage,
                ),
                SizedBox(height: spacings.spacing600),
                const _LoginButton(),
                if (messageState != null &&
                    messageState == MessageState.caution &&
                    helperBoxMessage != null) ...[
                  SizedBox(height: spacings.spacing300),
                  SeagullHelperBox(
                    text: helperBoxMessage,
                    state: messageState,
                    icon: helperBoxIcon,
                    size: HelperBoxSize.medium,
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData? _getHelperBoxIcon(LoginFailureCause? failureCause) {
  if (failureCause == null) return null;
  switch (failureCause) {
    case LoginFailureCause.noUsername:
    case LoginFailureCause.noPassword:
    case LoginFailureCause.credentials:
    case LoginFailureCause.licenseExpired:
    case LoginFailureCause.noLicense:
    case LoginFailureCause.unsupportedUserType:
    case LoginFailureCause.noConnection:
    case LoginFailureCause.notEmptyDatabase:
      return Symbols.error;
    case LoginFailureCause.tooManyAttempts:
      return Symbols.lightbulb;
  }
}

String? _getHelperBoxMessage(
  BuildContext context,
  LoginFailureCause? failureCause,
) {
  final translate = Lt.of(context);
  if (failureCause == null) return null;
  switch (failureCause) {
    case LoginFailureCause.noUsername:
    case LoginFailureCause.noPassword:
    case LoginFailureCause.credentials:
      return translate.verifyCredentials;
    case LoginFailureCause.licenseExpired:
      return translate.lincenseExpired;
    case LoginFailureCause.noLicense:
      return translate.noHandiLicence;
    case LoginFailureCause.unsupportedUserType:
      return translate.unsupportedUserType;
    case LoginFailureCause.tooManyAttempts:
      return translate.tooManyAttempts;
    case LoginFailureCause.noConnection:
      return translate.connectToInternet;
    case LoginFailureCause.notEmptyDatabase:
      return translate.somethingWentWrong;
  }
}

MessageState? _getMessageState(LoginFailureCause? failureCause) {
  if (failureCause == null) return null;
  switch (failureCause) {
    case LoginFailureCause.noUsername:
    case LoginFailureCause.noPassword:
    case LoginFailureCause.credentials:
    case LoginFailureCause.licenseExpired:
    case LoginFailureCause.noLicense:
    case LoginFailureCause.unsupportedUserType:
    case LoginFailureCause.notEmptyDatabase:
      return MessageState.error;
    case LoginFailureCause.tooManyAttempts:
    case LoginFailureCause.noConnection:
      return MessageState.caution;
  }
}
