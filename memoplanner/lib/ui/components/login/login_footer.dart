import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class MEMOplannerLoginFooter extends StatelessWidget {
  const MEMOplannerLoginFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tts(
          child: Text(
            Translator.of(context).translate.createAccountHint,
            style:
                (Theme.of(context).textTheme.bodyText1 ?? bodyText1).copyWith(
              color: AbiliaColors.black75,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity),
          child: const GoToCreateAccountButton()
              .pad(layout.login.createAccountPadding),
        ),
        Row(
          children: [
            AbiliaLogoWithReset(
              deviceRepository: context.read<DeviceRepository>(),
            ),
            const Spacer(),
            const IconActionButtonDark(
              onPressed: AndroidIntents.openSettings,
              child: Icon(AbiliaIcons.settings),
            ),
          ],
        ),
      ],
    );
  }
}

class GoToCreateAccountButton extends StatelessWidget {
  const GoToCreateAccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Tts.data(
      data: translate.createAccount,
      child: TextButton(
        style: textButtonStyleDarkGrey,
        onPressed: () async {
          final loginCubit = context.read<LoginCubit>();
          final username = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateAccountPage(
                userRepository: context.read<UserRepository>(),
              ),
            ),
          );
          if (username != null) {
            loginCubit.usernameChanged(username);
          }
        },
        child: Text(translate.createAccount),
      ),
    );
  }
}

class AbiliaLogoWithReset extends StatelessWidget {
  final DeviceRepository deviceRepository;

  const AbiliaLogoWithReset({
    required this.deviceRepository,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const AbiliaLogo(),
      onLongPress: () => showPersistentDialog(
        context: context,
        wrapWithAuthProviders: false,
        builder: (context) => ResetDeviceDialog(
          deviceRepository: deviceRepository,
        ),
      ),
    );
  }
}
