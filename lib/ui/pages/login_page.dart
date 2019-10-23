import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/repository/user_repository.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/abilia_button.dart';
import 'package:seagull/ui/components/login_form.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  const LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  onLogin(BuildContext context) {
    print("Login!");
    BlocProvider.of<LoginBloc>(context).add(
      LoginButtonPressed(
        username: 'mmm',
        password: 'mmmmmmmm',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return BlocProvider(
      builder: (context) {
        return LoginBloc(
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          userRepository: userRepository,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 76.0, left: 16, right: 16),
                  child: LoginForm(),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Builder(
                      builder: (context) => AbiliaButton(
                            label: i18n.translate("login"),
                            onPressed: () => onLogin(context)
                          )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
