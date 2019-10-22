import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: Image(
                        image: AssetImage(
                            'assets/graphics/seagull_icon_gray.png')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(i18n.translate('userName')),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField(
                            decoration: new InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(i18n.translate('password')),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextField(
                            obscureText: true,
                            decoration: new InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Use your ',
                          style: TextStyle(fontSize: 16),
                        ),
                        InkWell(
                            child: new Text(
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
                          ' account to login',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                    onPressed: onLogin,
                    child: Text('Login',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
