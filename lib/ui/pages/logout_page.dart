import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FlatButton(
            color: AbiliaColors.red,
            key: TestKey.loggInButton,
            child: Text(
              Translator.of(context).translate.logout,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: AbiliaColors.white),
            ),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ),
    );
  }
}
