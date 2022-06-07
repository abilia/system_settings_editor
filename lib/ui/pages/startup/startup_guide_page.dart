import 'package:seagull/ui/all.dart';

class StartupGuidePage extends StatelessWidget {
  const StartupGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WelcomePage(
              pageController: pageController,
            ),
            PageOne(
              pageController: pageController,
            ),
            PageTwo(
              pageController: pageController,
            ),
          ],
          controller: pageController,
        ),
      ),
    );
  }
}
