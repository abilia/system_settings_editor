import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/config.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

import 'package:seagull/ui/all.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key key,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  LoginFormBloc _loginFormBloc;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showBackends = false;

  @override
  void initState() {
    super.initState();

    _loginFormBloc = BlocProvider.of<LoginFormBloc>(context);
    _usernameController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = Theme.of(context);
    return BlocBuilder<LoginFormBloc, LoginFormState>(
      builder: (context, formState) => BlocBuilder<LoginBloc, LoginState>(
        builder: (context, loginState) {
          final errorState =
              loginState is LoginFailure && formState.formSubmitted;
          final credentialsError = errorState &&
              (loginState as LoginFailure).loginFailureCause ==
                  LoginFailureCause.Credentials;
          final licenseError =
              errorState && (loginState as LoginFailure).licenseError;
          return Form(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  padding56,
                  Center(
                    child: SizedBox(
                      width: 64.0.s,
                      height: 64.0.s,
                      child: loginState is LoginLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(AbiliaColors.red),
                              strokeWidth: 6.0.s,
                            )
                          : GestureDetector(
                              key: TestKey.loginLogo,
                              onLongPress: () => setState(
                                  () => _showBackends = !_showBackends),
                              child: FadeInImage(
                                fadeInDuration:
                                    const Duration(milliseconds: 50),
                                fadeInCurve: Curves.linear,
                                placeholder: MemoryImage(kTransparentImage),
                                image: AssetImage(
                                  'assets/graphics/${Config.flavor.id}/logo.png',
                                ),
                              ),
                            ),
                    ),
                  ),
                  padding32,
                  AbiliaTextInput(
                    formKey: TestKey.userNameInput,
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    icon: AbiliaIcons.contact,
                    heading: translate.userName,
                    inputHeading: translate.userNameTitle,
                    errorState: credentialsError,
                    autoCorrect: false,
                    inputValid: (s) => _loginFormBloc.isUsernameValid(s),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    ],
                  ),
                  padding16,
                  PasswordInput(
                    controller: _passwordController,
                    loginFormBloc: _loginFormBloc,
                    obscureText: formState.hidePassword,
                    errorState: credentialsError,
                  ),
                  if (Config.isMPGO) ...[
                    padding32,
                    Tts(
                      key: TestKey.loginHint,
                      child: Text(
                        translate.loginHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyText1
                            .copyWith(color: AbiliaColors.black75),
                      ),
                    ),
                    padding16,
                  ] else
                    const Spacer(flex: 92),
                  if (errorState && !licenseError) ...[
                    ErrorMessage(
                      key: TestKey.loginError,
                      text: Text(
                        (loginState as LoginFailure)
                            .loginFailureCause
                            .message(translate),
                      ),
                    ),
                    const Spacer(flex: 95),
                  ] else
                    const Spacer(flex: 191),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.s),
                    child: Theme(
                      data: redButtonTheme,
                      child: Tts(
                        data: translate.login,
                        child: FlatButton(
                          color: AbiliaColors.red,
                          disabledColor: AbiliaColors.red40,
                          key: TestKey.loggInButton,
                          onPressed: loginState is! LoginLoading &&
                                  formState.isFormValid
                              ? _onLoginButtonPressed
                              : null,
                          child: Text(
                            translate.login,
                            style: theme.textTheme.subtitle1
                                .copyWith(color: AbiliaColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  padding32,
                  CollapsableWidget(
                    collapsed: !_showBackends,
                    child: Column(
                      children: [
                        BackendSwitches(),
                        const Center(child: Version()),
                        SizedBox(height: 4.0.s),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Spacer get padding16 => const Spacer(flex: 16);
  Spacer get padding32 => const Spacer(flex: 32);
  Spacer get padding56 => const Spacer(flex: 56);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginButtonPressed() {
    BlocProvider.of<LoginBloc>(context).add(
      LoginButtonPressed(
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    _loginFormBloc.add(FormSubmitted());
  }

  void _onEmailChanged() {
    _loginFormBloc.add(UsernameChanged(username: _usernameController.text));
  }

  void _onPasswordChanged() {
    _loginFormBloc.add(PasswordChanged(password: _passwordController.text));
  }
}
