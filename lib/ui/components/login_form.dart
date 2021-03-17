import 'package:flutter/services.dart';
import 'package:seagull/config.dart';
import 'package:seagull/bloc/all.dart';
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
                  SizedBox(height: 56.s),
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
                              onLongPress: () {
                                _loginFormBloc.add(ResetForm());
                                setState(() => _showBackends = !_showBackends);
                              },
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
                  SizedBox(height: 32.s),
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
                  SizedBox(height: 16.s),
                  PasswordInput(
                    controller: _passwordController,
                    loginFormBloc: _loginFormBloc,
                    obscureText: formState.hidePassword,
                    errorState: credentialsError,
                  ),
                  SizedBox(height: 24.s),
                  if (Config.isMPGO) ...[
                    Tts(
                      key: TestKey.loginHint,
                      child: Text(
                        translate.loginHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyText1
                            .copyWith(color: AbiliaColors.black75),
                      ),
                    ),
                  ],
                  if (errorState &&
                      !licenseError &&
                      !(_showBackends && Config.isMPGO)) ...[
                    if (Config.isMPGO) SizedBox(height: 12.s),
                    ErrorMessage(
                      key: TestKey.loginError,
                      text: Text(
                        (loginState as LoginFailure)
                            .loginFailureCause
                            .message(translate),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.s),
                    child: LoginButton(
                      onPressed:
                          loginState is! LoginLoading && formState.isFormValid
                              ? _onLoginButtonPressed
                              : null,
                    ),
                  ),
                  SizedBox(height: 32.s),
                  CollapsableWidget(
                    collapsed: !_showBackends,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BackendSwitches(),
                        const Version(),
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

class LoginButton extends StatelessWidget {
  const LoginButton({
    Key key,
    this.onPressed,
  }) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Tts(
      data: translate.login,
      child: TextButton(
        style: textButtonStyleRed,
        onPressed: onPressed,
        child: Text(translate.login),
      ),
    );
  }
}
