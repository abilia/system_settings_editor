import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_button.dart';
import 'package:seagull/ui/components/seagull_icon.dart';
import 'package:seagull/ui/components/text_input.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key key,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

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
      child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        return Form(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 76.0, left: 16, right: 16),
                  child: Column(
                    children: <Widget>[
                      state is LoginLoading
                          ? CircularProgressIndicator()
                          : SeagullIcon(),
                      padding(),
                      TextInput(
                        label: i18n.translate('userName'),
                        controller: _usernameController,
                      ),
                      padding(),
                      TextInput(
                        label: i18n.translate('password'),
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      padding(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            i18n.translate('infoText1'),
                            style: TextStyle(fontSize: 16),
                          ),
                          GestureDetector(
                              child: Text(
                                'myAbilia',
                                style: TextStyle(
                                    color: RED,
                                    decoration: TextDecoration.underline,
                                    decorationColor: RED,
                                    fontSize: 16),
                              ),
                              onTap: () =>
                                  launch('https://myabilia.com/user-create')),
                          Text(
                            i18n.translate('infoText2'),
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                padding(),
                AbiliaButton(
                  label: i18n.translate('login'),
                  onPressed:
                      state is! LoginLoading ? _onLoginButtonPressed : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  padding() => const SizedBox(height: 32);
}
