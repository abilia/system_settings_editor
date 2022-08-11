import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/android_intents.dart';

class StartupGuidePage extends StatelessWidget {
  const StartupGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return MaterialAppWrapper(
      home: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            WelcomePage(
              pageController: pageController,
            ),
            PageOneWifi(
              pageController: pageController,
            ),
            PageTwoVoiceSupport(
              pageController: pageController,
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: layout.templates.m7.copyWith(top: 0),
          child: Row(
            children: const [
              AbiliaLogo(),
              Spacer(),
              IconActionButtonDark(
                onPressed: AndroidIntents.openSettings,
                child: Icon(AbiliaIcons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
