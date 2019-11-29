import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _loginFormBloc = BlocProvider.of<LoginFormBloc>(context);
    _usernameController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = Translator.of(context);
    return BlocBuilder<LoginFormBloc, LoginFormState>(
      builder: (context, formState) => BlocBuilder<LoginBloc, LoginState>(
        builder: (context, loginState) {
          bool errorState =
              loginState is LoginFailure && formState.formSubmitted;
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
                          : SeagullIcon()),
                  padding32,
                  Text(
                    i18n.translate.userName,
                    style: TextStyle(fontSize: 14),
                  ),
                  padding8,
                  TextFormField(
                    key: TestKey.userNameInput,
                    controller: _usernameController,
                    autovalidate: true,
                    validator: (_) => errorState ? '' : null,
                    decoration: errorState
                        ? InputDecoration(
                            suffixIcon: Icon(
                              AbiliaIcons.ir_error,
                              color: Theme.of(context).errorColor,
                            ),
                          )
                        : null,
                  ),
                  padding16,
                  Text(
                    i18n.translate.password,
                    style: TextStyle(fontSize: 14),
                  ),
                  padding8,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          key: TestKey.passwordInput,
                          obscureText: formState.hidePassword,
                          controller: _passwordController,
                          autovalidate: true,
                          validator: (_) => errorState ? '' : null,
                          decoration: errorState
                              ? InputDecoration(
                                  suffixIcon: Icon(
                                    AbiliaIcons.ir_error,
                                    color: Theme.of(context).errorColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (formState.password.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionButton(
                              key: TestKey.hidePasswordToggle,
                              child: Icon(formState.hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _onHidePasswordChanged,
                              themeData: showHideButtonTheme(context),
                            )),
                    ],
                  ),
                  padding32,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        i18n.translate.infoText1,
                        style: Theme.of(context).textTheme.body1,
                      ),
                      WebLink(
                        text: 'myAbilia',
                        urlString: 'https://myabilia.com/user-create',
                      ),
                      Text(
                        i18n.translate.infoText2,
                        style: Theme.of(context).textTheme.body1,
                      )
                    ],
                  ),
                  padding16,
                  if (errorState)
                    ErrorMessage(
                      key: TestKey.loginError,
                      child: Text(
                        i18n.translate.wrongCredentials,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  padding192,
                  AbiliaButton(
                    key: TestKey.loggInButton,
                    label: i18n.translate.login,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    onPressed:
                        loginState is! LoginLoading && formState.isFormValid
                            ? _onLoginButtonPressed
                            : null,
                  ),
                  padding16,
                  BackendSwitches(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  get padding8 => const SizedBox(height: 8);
  get padding16 => const Spacer(flex: 2);
  get padding32 => const Spacer(flex: 4);
  get padding56 => const Spacer(flex: 6);
  get padding192 => const Spacer(flex: 24);

  @override
  dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _onLoginButtonPressed() {
    BlocProvider.of<LoginBloc>(context).add(
      LoginButtonPressed(
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    _loginFormBloc.add(FormSubmitted());
  }

  _onEmailChanged() {
    _loginFormBloc.add(UsernameChanged(username: _usernameController.text));
  }

  _onPasswordChanged() {
    _loginFormBloc.add(PasswordChanged(password: _passwordController.text));
  }

  _onHidePasswordChanged() {
    _loginFormBloc.add(HidePasswordToggle());
  }
}
