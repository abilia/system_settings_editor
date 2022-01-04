import 'package:seagull/bloc/all.dart';
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
        Padding(
          padding: EdgeInsets.fromLTRB(16.s, 8.s, 16.s, 32.s),
          child: const GoToCreateAccountButton(),
        ),
        SizedBox(height: 32.s),
        Row(
          children: const [
            AbiliaLogo(),
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
          final username = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateAccountPage(
                userRepository:
                    context.read<AuthenticationBloc>().state.userRepository,
              ),
            ),
          );
          if (username != null) {
            context.read<LoginBloc>().add(UsernameChanged(username));
          }
        },
        child: Text(translate.createAccount),
      ),
    );
  }
}
