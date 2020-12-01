import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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

class ProfilePictureNameAndEmail extends StatefulWidget {
  @override
  _ProfilePictureNameAndEmailState createState() =>
      _ProfilePictureNameAndEmailState(GetIt.I<UserDb>().getUser());
}

class _ProfilePictureNameAndEmailState
    extends State<ProfilePictureNameAndEmail> {
  bool showVersion = false;
  final User user;
  _ProfilePictureNameAndEmailState(this.user);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onLongPress: () => Config.beta
              ? DatabaseRepository.logAll(GetIt.I<Database>())
              : GetIt.I<SeagullLogger>().sendLogsToBackend(),
          onDoubleTap: () => setState(() => showVersion = !showVersion),
          child: ProfilePicture(
            GetIt.I<BaseUrlDb>().getBaseUrl(),
            user,
          ),
        ),
        SizedBox(height: 24.0),
        Tts(
          child: Text(
            user.name,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        SizedBox(height: 4.0),
        if (user.username != null)
          Tts(
            child: Text(
              user.username,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: AbiliaColors.black75),
            ),
          ),
        if (showVersion) VersionInfo(showUserId: true),
      ],
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
            style: theme.textTheme.button,
          ),
          onPressed: () =>
              BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
        ),
      ),
    );
  }
}
