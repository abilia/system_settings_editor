import 'package:memoplanner/ui/all.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.pageController,
    Key? key,
  }) : super(key: key);

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return Padding(
      padding: layout.templates.m7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MEMOplannerLogoHiddenBackendSwitch(
            height: layout.startupPage.welcomeLogoHeight,
          ),
          SizedBox(height: layout.startupPage.welcomeLogoDistance),
          Text(translate.welcome,
              style: abiliaTextTheme.headlineMedium
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.formPadding.largeHorizontalItemDistance),
          Text(translate.welcomeText,
              style: abiliaTextTheme.bodyMedium
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.startupPage.startButtonDistance),
          SizedBox(
            height: layout.startupPage.buttonHeight,
            width: layout.startupPage.welcomeButtonWidth,
            child: TextButton(
              style: startPageButton,
              onPressed: () async => pageController.nextPage(
                duration: StartupGuidePage.pageDuration,
                curve: StartupGuidePage.curve,
              ),
              child: Text(
                translate.start,
                key: TestKey.startWelcomeGuide,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
