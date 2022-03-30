import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/ui/all.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.logout,
        label: Translator.of(context).translate.system,
        iconData: AbiliaIcons.powerOffOn,
      ),
      body: Padding(
        padding: layout.templates.l4,
        child: const Center(child: ProfilePictureNameAndEmail()),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: LogoutButton(),
      ),
    );
  }
}

class ProfilePictureNameAndEmail extends StatefulWidget {
  const ProfilePictureNameAndEmail({Key? key}) : super(key: key);
  @override
  _ProfilePictureNameAndEmailState createState() =>
      _ProfilePictureNameAndEmailState();
}

class _ProfilePictureNameAndEmailState
    extends State<ProfilePictureNameAndEmail> {
  bool showVersion = false;
  late final User? user;
  late final String baseUrl;
  late final String environment;

  @override
  void initState() {
    super.initState();
    user = GetIt.I<UserDb>().getUser();
    baseUrl = GetIt.I<BaseUrlDb>().baseUrl;
    environment = backendEnvironments[baseUrl] ?? 'Prod';
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Column(
      children: <Widget>[
        if (user != null) ...[
          GestureDetector(
            onLongPress: () => Config.beta
                ? DatabaseRepository.logAll(GetIt.I<Database>())
                : GetIt.I<SeagullLogger>().sendLogsToBackend(),
            onDoubleTap: () => setState(() => showVersion = !showVersion),
            child: ProfilePicture(
              baseUrl,
              user,
            ),
          ),
          SizedBox(height: layout.logout.profileDistance),
          Tts(
            child: Text(
              user.name,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          if (user.username.isNotEmpty)
            Tts(
              child: Text(
                user.username,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: AbiliaColors.black75),
              ),
            ),
          if (showVersion) Text('${user.id} ($environment)'),
        ]
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: Translator.of(context).translate.logout,
        icon: AbiliaIcons.powerOffOn,
        onPressed: () =>
            BlocProvider.of<AuthenticationBloc>(context).add(const LoggedOut()),
        style: iconTextButtonStyleRed,
      );
}
