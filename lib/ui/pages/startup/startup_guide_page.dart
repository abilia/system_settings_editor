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

class PageTwo extends StatelessWidget {
  const PageTwo({
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
          const MEMOplannerLogo(
            height: 96,
          ),
          SizedBox(height: layout.startupPageLayout.logoDistance),
          Text('${t.step} 2/2',
              style: abiliaTextTheme.bodyText2
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.formPadding.smallVerticalItemDistance),
          Text(
            t.downloadVoiceText,
            style: abiliaTextTheme.headline6
                ?.copyWith(color: AbiliaColors.black75),
          ),
          SizedBox(height: layout.startupPageLayout.textPickDistance),
          SizedBox(
            width: 540,
            child: PickField(
              leading: const Icon(AbiliaIcons.speakText),
              text: Text(t.textToSpeech),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: copiedAuthProviders(context),
                    child: SpeechSupportSettingsPage(
                      textToSpeech:
                          context.read<SettingsCubit>().state.textToSpeech,
                      speechRate:
                          context.read<SpeechSettingsCubit>().state.speechRate,
                    ),
                  ),
                  settings:
                      const RouteSettings(name: 'SpeechSupportSettingsPage'),
                ),
              ),
            ),
          ),
          SizedBox(
            height: layout.startupPageLayout.textPickDistance,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 264,
                child: IconAndTextButton(
                  onPressed: () {
                    pageController.previousPage(
                        duration: 500.milliseconds(),
                        curve: Curves.easeOutQuad);
                  },
                  text: t.back,
                  style: textButtonStyleDarkGrey,
                  icon: AbiliaIcons.navigationPrevious,
                ),
              ),
              SizedBox(
                width: layout.formPadding.horizontalItemDistance,
              ),
              SizedBox(
                width: 264,
                child: IconAndTextButton(
                  onPressed: () {
                    context.read<ProductionGuideCubit>().startGuideDone();
                  },
                  text: t.finsish,
                  icon: AbiliaIcons.ok,
                  style: textButtonStyleGreen,
                ),
              ),
            ],
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

  void _showVoicesPage(BuildContext context, String locale) async {
    final authProviders = copiedAuthProviders(context);

    await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: const VoicesPage(),
        ),
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({
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
          const MEMOplannerLogo(
            height: 96,
          ),
          SizedBox(height: layout.startupPageLayout.logoDistance),
          Text('${t.step} 1/2',
              style: abiliaTextTheme.bodyText2
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.formPadding.smallVerticalItemDistance),
          Text(
            t.checkInternetConnection,
            style: abiliaTextTheme.headline6
                ?.copyWith(color: AbiliaColors.black75),
          ),
          SizedBox(height: layout.startupPageLayout.textPickDistance),
          const WiFiPickField(),
          FutureBuilder(
              future: Connectivity().checkConnectivity(),
              builder: ((context, snapshot) =>
                  snapshot.hasData && snapshot.data != ConnectivityResult.none
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: layout.startupPageLayout.textPickDistance),
                          child: TextButton(
                            style: textButtonStyleGreen,
                            onPressed: () {
                              pageController.nextPage(
                                duration: 500.milliseconds(),
                                curve: Curves.easeOutQuad,
                              );
                            },
                            child: Text(t.next),
                          ),
                        )
                      : Container())),
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
          const MEMOplannerLogo(
            height: 164,
          ),
          SizedBox(height: layout.formPadding.largeGroupDistance),
          Text(t.welcome,
              style: abiliaTextTheme.headline4
                  ?.copyWith(color: AbiliaColors.black75)),
          SizedBox(height: layout.formPadding.largeHorizontalItemDistance),
          Text(t.welcomeText,
              style: abiliaTextTheme.bodyText2
                  ?.copyWith(color: AbiliaColors.black75)),
          const SizedBox(height: 64),
          TextButton(
            style: textButtonStyleGreen,
            onPressed: () {
              pageController.nextPage(
                  duration: 500.milliseconds(), curve: Curves.easeOutQuad);
            },
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
    );
  }
}
