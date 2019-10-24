import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/bloc/login/form/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/abilia_button.dart';
import 'package:seagull/ui/components/action_button.dart';
import 'package:seagull/ui/components/seagull_icon.dart';
import 'package:seagull/ui/components/web_link.dart';

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
    final i18n = AppLocalizations.of(context);
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(i18n.translate('wrong_credentials')),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, loginState) =>
            BlocBuilder<LoginFormBloc, LoginFormState>(
          builder: (context, formState) => Form(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 76.0, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                            child: loginState is LoginLoading
                                ? CircularProgressIndicator()
                                : SeagullIcon()),
                        padding32,
                        Text(
                          i18n.translate('userName'),
                          style: TextStyle(fontSize: 14),
                        ),
                        padding8,
                        TextFormField(
                          controller: _usernameController,
                          autovalidate: true,
                        ),
                        padding16,
                        Text(
                          i18n.translate('password'),
                          style: TextStyle(fontSize: 14),
                        ),
                        padding8,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                obscureText: formState.hidePassword,
                                controller: _passwordController,
                                autovalidate: true,
                              ),
                            ),
                            if (formState.hasPassword)
                              Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: ActionButton(
                                    child: Icon(formState.hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: _onHidePasswordChanged,
                                  )),
                          ],
                        ),
                        padding32,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              i18n.translate('infoText1'),
                              style: TextStyle(fontSize: 16),
                            ),
                            WebLink(
                              text: 'myAbilia',
                              urlString: 'https://myabilia.com/user-create',
                            ),
                            Text(
                              i18n.translate('infoText2'),
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  padding32,
                  AbiliaButton(
                    label: i18n.translate('login'),
                    onPressed:
                        loginState is! LoginLoading && formState.isFormValid
                            ? _onLoginButtonPressed
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  get padding8 => const SizedBox(height: 8);
  get padding16 => const SizedBox(height: 16);
  get padding32 => const SizedBox(height: 32);

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
