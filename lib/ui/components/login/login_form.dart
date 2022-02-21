import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/ui/all.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = Theme.of(context);
    return BlocBuilder<LoginCubit, LoginState>(
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
                    style: (theme.textTheme.bodyText1 ?? bodyText1)
                        .copyWith(color: AbiliaColors.black75),
                  ),
                ),
                SizedBox(height: 32.s),
                UsernameInput(
                  initialValue: state.username,
                  errorState: state.usernameError,
                  onChanged: (newUsername) =>
                      context.read<LoginCubit>().usernameChanged(newUsername),
                ),
                SizedBox(height: 16.s),
                PasswordInput(
                  errorState: state.passwordError,
                  password: state.password,
                  onPasswordChange: (newPassword) =>
                      context.read<LoginCubit>().passwordChanged(newPassword),
                  validator: LoginCubit.passwordValid,
                ),
                SizedBox(height: 32.s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.s),
                  child: const LoginButton(),
                ),
                const Spacer(),
                if (Config.isMP)
                  const MEMOplannerLoginFooter()
                else
                  const AbiliaLogo(),
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
    Key? key,
    required this.initialValue,
    this.errorState = false,
    this.onChanged,
    this.inputValid,
  }) : super(key: key);

  final String initialValue;
  final bool errorState;
  final void Function(String)? onChanged;
  final bool Function(String)? inputValid;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return AbiliaTextInput(
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
      icon: AbiliaIcons.contact,
      heading: translate.usernameHint,
      inputHeading: translate.username,
      errorState: errorState,
      autoCorrect: false,
      inputValid: inputValid ?? LoginCubit.usernameValid,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      onChanged: onChanged,
    );
  }
}

class MEMOplannerLogo extends StatelessWidget {
  const MEMOplannerLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => SizedBox(
        width: 64.s,
        height: 64.s,
        child: state is LoginLoading
            ? CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation(AbiliaColors.red),
                strokeWidth: 6.s,
              )
            : GestureDetector(
                onLongPress: () {
                  context.read<LoginCubit>().clearFailure();
                  showDialog(
                    context: context,
                    builder: (context) => const BackendSwitchesDialog(),
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
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Tts.data(
      data: translate.login,
      child: BlocBuilder<BaseUrlCubit, String>(builder: (context, baseUrl) {
        final end = baseUrl == prod
            ? ''
            : ' (${backendEnvironments[baseUrl] ?? baseUrl})';
        return BlocBuilder<LoginCubit, LoginState>(
        builder: (context, end) => BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) => TextButton(
            style: textButtonStyleGreen,
            onPressed: state is! LoginLoading
                ? () {
                    BlocProvider.of<LoginCubit>(context).loginButtonPressed();
                    FocusScope.of(context).requestFocus(FocusNode());
                  }
                : null,
            child: Text('${translate.login}$end'),
          ),
        );
      }),
    );
  }
}
