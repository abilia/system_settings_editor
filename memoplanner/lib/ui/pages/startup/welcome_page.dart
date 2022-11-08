import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.pageController,
    Key? key,
  }) : super(key: key);

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Padding(
      padding: layout.templates.m7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MEMOplannerLogo(
            height: layout.startupPage.welcomeLogoHeight,
          ),
          SizedBox(height: layout.startupPage.welcomeLogoDistance),
          Text(t.welcome,
              style: abiliaTextTheme.headline4
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.formPadding.largeHorizontalItemDistance),
          Text(t.welcomeText,
              style: abiliaTextTheme.bodyText2
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.startupPage.startButtonDistance),
          SizedBox(
            height: layout.startupPage.buttonHeight,
            width: layout.startupPage.welcomeButtonWidth,
            child: TextButton(
              style: startPageButton,
              onPressed: () {
                pageController.nextPage(
                    duration: 500.milliseconds(), curve: Curves.easeOutQuad);
              },
              child: Text(
                t.start,
                key: TestKey.startWelcomGuide,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
