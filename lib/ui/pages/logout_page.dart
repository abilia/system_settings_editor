import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/ui/all.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: Translator.of(context).translate.logout,
        iconData: AbiliaIcons.power_off_on,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Center(child: ProfilePictureNameAndEmail()),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: LogoutButton(),
      ),
    );
  }
}

class ProfilePictureNameAndEmail extends StatefulWidget {
  @override
  _ProfilePictureNameAndEmailState createState() =>
      _ProfilePictureNameAndEmailState(
        user: GetIt.I<UserDb>().getUser(),
        baseUrl: GetIt.I<BaseUrlDb>().getBaseUrl(),
      );
}

class _ProfilePictureNameAndEmailState
    extends State<ProfilePictureNameAndEmail> {
  bool showVersion = false;
  final User user;
  final String enviorment;
  _ProfilePictureNameAndEmailState({
    this.user,
    String baseUrl,
  }) : enviorment = backEndEnviorments.map((k, v) => MapEntry(v, k))[baseUrl];
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
        if (showVersion) Text('${user.id} ($enviorment)'),
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: Translator.of(context).translate.logout,
        icon: AbiliaIcons.power_off_on,
        onPressed: () =>
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
        theme: logoutButtonTheme,
      );
}
