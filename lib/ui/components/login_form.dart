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
    return BlocBuilder<LoginFormBloc, LoginFormState>(
      builder: (context, formState) => BlocBuilder<LoginBloc, LoginState>(
        builder: (context, loginState) {
          final errorState =
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
                  TextFormInput(
                    formKey: TestKey.userNameInput,
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    heading: i18n.translate.userName,
                    errorState: errorState,
                  ),
                  padding16,
                  TextFormInput(
                    formKey: TestKey.passwordInput,
                    controller: _passwordController,
                    heading: i18n.translate.password,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: formState.hidePassword,
                    errorState: errorState,
                    trailing: formState.password.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: ActionButton(
                              key: TestKey.hidePasswordToggle,
                              child: Icon(
                                formState.hidePassword
                                    ? AbiliaIcons.show
                                    : AbiliaIcons.hide,
                                size: 32,
                                color: AbiliaColors.black,
                              ),
                              onPressed: _onHidePasswordChanged,
                              themeData: darkButtonTheme,
                            ),
                          )
                        : null,
                  ),
                  padding32,
                  _LoginHint(),
                  padding16,
                  if (errorState)
                    ErrorMessage(
                      key: TestKey.loginError,
                      child: Text(
                        i18n.translate.wrongCredentials,
                        style: theme.textTheme.bodyText2,
                      ),
                    ),
                  flexPadding(errorState),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Theme(
                      data: redButtonTheme,
                      child: FlatButton(
                        color: AbiliaColors.red,
                        disabledColor: AbiliaColors.red40,
                        key: TestKey.loggInButton,
                        child: Text(
                          i18n.translate.login,
                          style: theme.textTheme.subtitle1
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

  void _onHidePasswordChanged() {
    _loginFormBloc.add(HidePasswordToggle());
  }
}

class _LoginHint extends StatelessWidget {
  const _LoginHint({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyText12Grey = Theme.of(context)
        .textTheme
        .bodyText1
        .copyWith(color: AbiliaColors.black75);
    final translate = Translator.of(context).translate;
    ;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          translate.infoText1,
          style: bodyText12Grey,
        ),
        WebLink(
          text: 'myAbilia',
          urlString: 'https://myabilia.com/user-create',
        ),
        Text(
          translate.infoText2,
          style: bodyText12Grey,
        )
      ],
    );
  }
}
