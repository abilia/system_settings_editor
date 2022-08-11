import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
          children: const [
            AbiliaLogoWithReset(),
            Spacer(),
            IconActionButtonDark(
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
  const AbiliaLogoWithReset({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final voicesCubit = context.read<VoicesCubit>();
    final startupCubit = context.read<StartupCubit>();
    return GestureDetector(
      child: const AbiliaLogo(),
      onLongPress: () async {
        final reset = await showViewDialog<bool>(
          context: context,
          wrapWithAuthProviders: false,
          builder: (context) => YesNoDialog(
            heading: translate.resetDeviceHeading,
            headingIcon: AbiliaIcons.reset,
            text: translate.resetDeviceBody,
          ),
        );
        if (reset == true) {
          voicesCubit.deleteAllVoices();
          startupCubit.resetStartGuideDone();
        }
      },
    );
  }
}
