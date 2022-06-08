import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    Key? key,
    required this.pageController,
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
          const MEMOplannerLogoLarge(),
          SizedBox(height: layout.startupPageLayout.welcomeLogoDistance),
          Text(t.welcome,
              style: abiliaTextTheme.headline4
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.formPadding.largeHorizontalItemDistance),
          Text(t.welcomeText,
              style: abiliaTextTheme.bodyText2
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.startupPageLayout.startButtonDistance),
          SizedBox(
            height: layout.startupPageLayout.buttonHeight,
            width: layout.startupPageLayout.welcomeButtonWidth,
            child: TextButton(
              style: startPageButton,
              onPressed: () {
                pageController.nextPage(
                    duration: 500.milliseconds(), curve: Curves.easeOutQuad);
              },
              child: Text(t.start),
            ),
          ),
          const Spacer(),
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
      ),
    );
  }
}
