import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/repository/end_point.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

part 'warning_modal.dart';

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
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: LogoutButton(
          onPressed: () => _logOutPressed(context),
        ),
      ),
    );
  }

  Future<void> _logOutPressed(BuildContext context) async {
    Future<void> onLogoutPressed(BuildContext context) async {
      final authContext = BlocProvider.of<AuthenticationBloc>(context);
      if (context.read<LicenseCubit>().state is ValidLicense) {
        authContext.add(const LoggedOut());
      }
    }

    if (context.read<SyncBloc>().isSynced) {
      onLogoutPressed(context);
    } else {
      await showAbiliaBottomSheet(
        context: context,
        providers: copiedAuthProviders(context),
        child: Padding(
          padding: layout.templates.s5,
          child: Center(
            child: BlocProvider<LogoutSyncCubit>(
              create: (context) => LogoutSyncCubit(
                syncBloc: context.read<SyncBloc>(),
                licenseCubit: context.read<LicenseCubit>(),
                connectivity: Connectivity().onConnectivityChanged,
                myAbiliaConnection: MyAbiliaConnection(),
              ),
              child: WarningModal(
                onLogoutPressed: onLogoutPressed,
              ),
            ),
          ),
        ),
      );
    }
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
  const LogoutButton({
    required this.onPressed,
    this.style,
    super.key,
  });
  final ButtonStyle? style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: Translator.of(context).translate.logout,
        icon: AbiliaIcons.powerOffOn,
        onPressed: onPressed,
        style: style ?? iconTextButtonStyleRed,
      );
}
