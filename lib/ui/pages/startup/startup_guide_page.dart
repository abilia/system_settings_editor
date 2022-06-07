import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class StartupGuidePage extends StatelessWidget {
  const StartupGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: PageView(
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
