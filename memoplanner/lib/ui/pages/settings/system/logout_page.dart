import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/repository/end_point.dart';
import 'package:memoplanner/ui/all.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.logout,
        label: Config.isMP ? Translator.of(context).translate.system : null,
        iconData: AbiliaIcons.powerOffOn,
      ),
      body: Center(
        child: const ProfilePictureNameAndEmail().pad(
          EdgeInsets.only(top: layout.logout.topDistance),
        ),
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
  State createState() => _ProfilePictureNameAndEmailState();
}

class _ProfilePictureNameAndEmailState
    extends State<ProfilePictureNameAndEmail> {
  bool showVersion = false;
  late final User? user;
  late final String baseUrl;

  @override
  void initState() {
    super.initState();
    user = GetIt.I<UserDb>().getUser();
    baseUrl = GetIt.I<BaseUrlDb>().baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Column(
      children: <Widget>[
        if (user != null) ...[
          GestureDetector(
            onLongPress: () => GetIt.I<SeagullLogger>().sendLogsToBackend(),
            onDoubleTap: () => setState(() => showVersion = !showVersion),
            child: ProfilePicture(
              baseUrl,
              user.image,
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
          if (showVersion) Text('${user.id} (${backendName(baseUrl)})'),
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
        onPressed: () async {
          final authContext = BlocProvider.of<AuthenticationBloc>(context);
          if (BlocProvider.of<LicenseCubit>(context).state is ValidLicense) {
            authContext.add(const LoggedOut());
          } else {
            final confirmWarningDialog = await showViewDialog(
              context: context,
              builder: (context) => ConfirmWarningDialog(
                text: Translator.of(context)
                    .translate
                    .licenseExpiredLogOutWarning,
              ),
            );
            if (confirmWarningDialog) {
              authContext.add(const LoggedOut());
            }
          }
        },
        style: iconTextButtonStyleRed,
      );
}
