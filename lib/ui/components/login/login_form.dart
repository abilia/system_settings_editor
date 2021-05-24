import 'package:flutter/services.dart';
import 'package:seagull/config.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';

import 'package:seagull/ui/all.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = Theme.of(context);
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Form(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              48.s,
              horizontalPadding,
              horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const MEMOplannerLogo(),
                SizedBox(height: 16.s),
                Tts(
                  child: Text(
                    Config.isMPGO
                        ? translate.loginHintMPGO
                        : translate.loginHintMP,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyText1
                        .copyWith(color: AbiliaColors.black75),
                  ),
                ),
                SizedBox(height: 32.s),
                UsernameInput(
                  initialValue: state.username,
                  errorState: state.usernameError,
                  onChanged: (newUsername) => context.read<LoginBloc>().add(
                        UsernameChanged(newUsername),
                      ),
                ),
                SizedBox(height: 16.s),
                PasswordInput(
                  errorState: state.passwordError,
                  password: state.password,
                  onPasswordChange: (newPassword) => context
                      .read<LoginBloc>()
                      .add(PasswordChanged(newPassword)),
                  validator: LoginBloc.passwordValid,
                ),
                SizedBox(height: 32.s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.s),
                  child: const LoginButton(),
                ),
                const Spacer(),
                if (Config.isMP) MEMOplannerLoginFooter() else AbiliaLogo(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UsernameInput extends StatelessWidget {
  const UsernameInput({
    Key key,
    this.initialValue,
    this.errorState,
    this.onChanged,
    this.inputValid,
  }) : super(key: key);

  final String initialValue;
  final bool errorState;
  final void Function(String) onChanged;
  final bool Function(String) inputValid;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return AbiliaTextInput(
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
      icon: AbiliaIcons.contact,
      heading: translate.username,
      inputHeading: translate.usernameTitle,
      errorState: errorState,
      autoCorrect: false,
      inputValid: inputValid ?? LoginBloc.usernameValid,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      onChanged: onChanged,
    );
  }
}

class MEMOplannerLogo extends StatelessWidget {
  const MEMOplannerLogo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) => SizedBox(
        width: 64.s,
        height: 64.s,
        child: state is LoginLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AbiliaColors.red),
                strokeWidth: 6.s,
              )
            : GestureDetector(
                onLongPress: () {
                  context.read<LoginBloc>().add(ClearFailure());
                  showDialog(
                    context: context,
                    builder: (context) => BackendSwitchesDialog(),
                  );
                },
                child: FadeInImage(
                  fadeInDuration: const Duration(milliseconds: 50),
                  fadeInCurve: Curves.linear,
                  placeholder: MemoryImage(kTransparentImage),
                  image: AssetImage(
                    'assets/graphics/${Config.flavor.id}/logo.png',
                  ),
                ),
              ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Tts(
      data: translate.login,
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) => TextButton(
          style: textButtonStyleGreen,
          onPressed: state is! LoginLoading
              ? () {
                  BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed());
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              : null,
          child: Text(translate.login),
        ),
      ),
    );
  }
}
