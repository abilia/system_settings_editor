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
                          : SeagullIcon()),
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
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionButton(
                              key: TestKey.hidePasswordToggle,
                              child: Icon(formState.hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _onHidePasswordChanged,
                              themeData: showHideButtonTheme(),
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
                  padding192,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  padding16,
                  BackendSwitches(),
                  Center(
                    child: FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, AsyncSnapshot<PackageInfo> snapshot) =>
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
