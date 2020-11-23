import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

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
          final licenseError = errorState &&
              (loginState as LoginFailure).loginFailureCause ==
                  LoginFailureCause.License;
          return Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  padding56,
                  Center(
                    child: loginState is LoginLoading
                        ? CircularProgressIndicator()
                        : GestureDetector(
                            child: SeagullIcon(),
                            onDoubleTap: () =>
                                setState(() => _showBackends = !_showBackends),
                          ),
                  ),
                  padding32,
                  AbiliaTextInput(
                    formKey: TestKey.userNameInput,
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    heading: translate.userName,
                    errorState: credentialsError,
                  ),
                  padding16,
                  PasswordInput(
                    controller: _passwordController,
                    loginFormBloc: _loginFormBloc,
                    obscureText: formState.hidePassword,
                    errorState: credentialsError,
                  ),
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
                  if (errorState && !licenseError)
                    ErrorMessage(
                      key: TestKey.loginError,
                      text: Text(
                        _errorMessageFromState(loginState, translate),
                      ),
                    ),
                  flexPadding(errorState),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Theme(
                      data: redButtonTheme,
                      child: Tts(
                        data: translate.login,
                        child: FlatButton(
                          color: AbiliaColors.red,
                          disabledColor: AbiliaColors.red40,
                          key: TestKey.loggInButton,
                          child: Text(
                            translate.login,
                            style: theme.textTheme.subtitle1
                                .copyWith(color: AbiliaColors.white),
                          ),
                          onPressed: loginState is! LoginLoading &&
                                  formState.isFormValid
                              ? _onLoginButtonPressed
                              : null,
                        ),
                      ),
                    ),
                  ),
                  padding32,
                  if (_showBackends) ...[
                    BackendSwitches(),
                    VersionInfo(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SizedBox get padding8 => const SizedBox(height: 8.0);
  Spacer get padding16 => const Spacer(flex: 16);
  Spacer get padding32 => const Spacer(flex: 32);
  Spacer get padding56 => const Spacer(flex: 56);
  Spacer flexPadding(bool errorState) =>
      errorState ? const Spacer(flex: 95) : const Spacer(flex: 191);

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

  String _errorMessageFromState(LoginFailure loginState, Translated translate) {
    switch (loginState.loginFailureCause) {
      case LoginFailureCause.Credentials:
        return translate.wrongCredentials;
      case LoginFailureCause.NoConnection:
        return translate.noConnection;
      case LoginFailureCause.License:
        return translate.noLicense;
      default:
        return loginState.error;
    }
  }
}
