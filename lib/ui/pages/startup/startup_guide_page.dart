import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class StartupGuidePage extends StatelessWidget {
  const StartupGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: Padding(
          padding: layout.templates.m7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const MEMOplannerLogo(
                height: 164,
              ),
              SizedBox(height: layout.formPadding.largeGroupDistance),
              Text('Welcome!', style: abiliaTextTheme.headline4),
              SizedBox(height: layout.formPadding.largeHorizontalItemDistance),
              const Text(
                  'This guide will help you get started with MEMOplanner'),
              const SizedBox(height: 64),
              TextButton(
                style: textButtonStyleGreen,
                onPressed: () {},
                child: const Text('Start'),
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
        ),
      ),
    );
  }
}
