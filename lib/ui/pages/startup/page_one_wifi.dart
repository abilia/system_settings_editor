import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PageOneWifi extends StatelessWidget {
  const PageOneWifi({
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
            height: layout.login.logoHeight,
          ),
          SizedBox(height: layout.startupPage.logoDistance),
          Tts(
            child: Text('${t.step} 1/2',
                style: abiliaTextTheme.bodyText2
                    ?.copyWith(color: AbiliaColors.black75)),
          ),
          SizedBox(height: layout.formPadding.smallVerticalItemDistance),
          Tts(
            child: Text(
              t.checkInternetConnection,
              style: abiliaTextTheme.headline6
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
          SizedBox(height: layout.startupPage.textPickDistance),
          SizedBox(
            width: layout.startupPage.contentWidth,
            child: const WiFiPickField(),
          ),
          SizedBox(height: layout.startupPage.textPickDistance),
          StreamBuilder<ConnectivityResult>(
            stream: Connectivity().onConnectivityChanged,
            builder: (context, _) => FutureBuilder(
              future: Connectivity().checkConnectivity(),
              builder: ((context, snapshot) =>
                  snapshot.hasData && snapshot.data != ConnectivityResult.none
                      ? SizedBox(
                          width: layout.startupPage.contentWidth,
                          child: Tts.data(
                            data: t.next,
                            child: TextButton(
                              style: textButtonStyleGreen,
                              onPressed: () {
                                pageController.nextPage(
                                  duration: 500.milliseconds(),
                                  curve: Curves.easeOutQuad,
                                );
                              },
                              child: Text(
                                t.next,
                                key: TestKey.nextWelcomeGuide,
                              ),
                            ),
                          ),
                        )
                      : Container()),
            ),
          ),
        ],
      ),
    );
  }
}
