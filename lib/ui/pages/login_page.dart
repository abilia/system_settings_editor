import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/abilia_button.dart';
import 'package:seagull/ui/components/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    Key key,
  }) : super(key: key);

  onLogin() {
    print("Login!");
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 76.0, left: 16, right: 16),
                child: LoginForm(),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: AbiliaButton(
                  label: i18n.translate("login"),
                  onPressed: onLogin,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
