import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.logout,
        closeIcon: AbiliaIcons.navigation_previous,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 32.0),
            ProfilePictureNameAndEmail(),
            Spacer(),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class ProfilePictureNameAndEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => FutureBuilder(
        future: state is Authenticated
            ? state.userRepository.me(state.token)
            : null,
        builder: (context, AsyncSnapshot<User> userSnapshot) => Column(
          children: <Widget>[
            GestureDetector(
              onDoubleTap: () =>
                  DatabaseRepository.logAll(GetIt.I<Database>()),
              child: ProfilePicture(
                  state is AuthenticationInitialized
                      ? state.userRepository.baseUrl
                      : null,
                  userSnapshot.data),
            ),
            SizedBox(height: 24.0),
            if (userSnapshot.data?.name?.isNotEmpty == true)
              Tts(
                child: Text(
                  userSnapshot.data.name,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            SizedBox(height: 4.0),
            if (userSnapshot.data?.username?.isNotEmpty == true)
              Tts(
                child: Text(
                  userSnapshot.data.username,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: AbiliaColors.black75),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = redButtonTheme;
    final text = Translator.of(context).translate.logout;
    return Theme(
      data: theme,
      child: Tts(
        data: text,
        child: FlatButton(
          color: theme.buttonColor,
          key: TestKey.loggInButton,
          child: Text(
            text,
            style:
                theme.textTheme.subtitle1.copyWith(color: AbiliaColors.white),
          ),
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
