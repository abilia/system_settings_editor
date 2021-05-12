import 'package:seagull/ui/all.dart';

class CreateAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigation(
        forwardNavigationWidget: CreateAccountButton(),
        backNavigationWidget: BackToLoginButton(),
      ),
    );
  }
}

class BackToLoginButton extends StatelessWidget {
  const BackToLoginButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      icon: AbiliaIcons.navigation_previous,
      text: Translator.of(context).translate.back,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      icon: AbiliaIcons.ok,
      text: Translator.of(context).translate.ok,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}
