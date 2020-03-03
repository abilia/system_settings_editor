import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:package_info/package_info.dart';

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
    final i18n = Translator.of(context);
    final theme = Theme.of(context);
    final body1Grey =
        theme.textTheme.body1.copyWith(color: AbiliaColors.black[75]);
    final body2Grey =
        theme.textTheme.body2.copyWith(color: AbiliaColors.black[75]);
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
                          : GestureDetector(
                              child: SeagullIcon(),
                              onDoubleTap: () => setState(
                                  () => _showBackends = !_showBackends),
                            )),
                  padding32,
                  Text(
                    i18n.translate.userName,
                    style: body1Grey,
                  ),
                  padding8,
                  TextFormField(
                    key: TestKey.userNameInput,
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    style: theme.textTheme.body2,
                    autovalidate: true,
                    validator: (_) => errorState ? '' : null,
                    decoration: errorState
                        ? InputDecoration(
                            suffixIcon: Icon(
                              AbiliaIcons.ir_error,
                              color: theme.errorColor,
                            ),
                          )
                        : null,
                  ),
                  padding16,
                  Text(
                    i18n.translate.password,
                    style: body1Grey,
                    key: Key('passwordLabel'),
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
                          keyboardType: TextInputType.visiblePassword,
                          style: theme.textTheme.body2,
                          autovalidate: true,
                          validator: (_) => errorState ? '' : null,
                          decoration: errorState
                              ? InputDecoration(
                                  suffixIcon: Icon(
                                    AbiliaIcons.ir_error,
                                    color: theme.errorColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (formState.password.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: ActionButton(
                              key: TestKey.hidePasswordToggle,
                              child: Icon(formState.hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _onHidePasswordChanged,
                              themeData: darkButtonTheme,
                            )),
                    ],
                  ),
                  padding32,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        i18n.translate.infoText1,
                        style: body2Grey,
                      ),
                      WebLink(
                        text: 'myAbilia',
                        urlString: 'https://myabilia.com/user-create',
                      ),
                      Text(
                        i18n.translate.infoText2,
                        style: body2Grey,
                      )
                    ],
                  ),
                  padding16,
                  if (errorState)
                    ErrorMessage(
                      key: TestKey.loginError,
                      child: Text(
                        i18n.translate.wrongCredentials,
                        style: theme.textTheme.body1,
                      ),
                    ),
                  flexPadding(errorState),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Theme(
                      data: redButtonTheme,
                      child: FlatButton(
                        color: AbiliaColors.red,
                        disabledColor: AbiliaColors.red[40],
                        key: TestKey.loggInButton,
                        child: Text(
                          i18n.translate.login,
                          style: theme.textTheme.subhead
                              .copyWith(color: AbiliaColors.white),
                        ),
                        onPressed: loginState is! LoginLoading &&
                                formState.isFormValid &&
                                !(errorState)
                            ? _onLoginButtonPressed
                            : null,
                      ),
                    ),
                  ),
                  padding32,
                  if (_showBackends) BackendSwitches(),
                  if (_showBackends)
                    Center(
                      child: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context,
                                AsyncSnapshot<PackageInfo> snapshot) =>
                            Text(snapshot.hasData
                                ? '${snapshot.data.version}(${snapshot.data.buildNumber})'
                                : ''),
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

  get padding8 => const SizedBox(height: 8.0);
  get padding16 => const Spacer(flex: 16);
  get padding32 => const Spacer(flex: 32);
  get padding56 => const Spacer(flex: 56);
  flexPadding(bool errorState) =>
      errorState ? const Spacer(flex: 95) : const Spacer(flex: 191);

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
