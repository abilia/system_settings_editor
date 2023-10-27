part of 'login_page.dart';

class _WelcomeToHandiText extends StatelessWidget {
  const _WelcomeToHandiText();

  @override
  Widget build(BuildContext context) {
    return Text(
      Lt.of(context).welcomeToHandi,
      style: AbiliaTheme.of(context).textStyles.primary525,
      textAlign: TextAlign.center,
    );
  }
}
