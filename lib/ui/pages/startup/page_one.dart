import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
          const MEMOplannerLogo(),
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
          const SizedBox(width: 540, child: WiFiPickField()),
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
