import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class PageOneWifi extends StatelessWidget {
  const PageOneWifi({
    required this.pageController,
    required this.pages,
    Key? key,
  }) : super(key: key);

  final PageController pageController;
  final int pages;

  @override
  Widget build(BuildContext context) {
    final startUpState = context.watch<StartupCubit>().state;
    final connectivityState = context.watch<ConnectivityCubit>().state;
    final t = Translator.of(context).translate;
    return Padding(
      padding: layout.templates.m7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MEMOplannerLogoHiddenBackendSwitch(
            loading: startUpState is LoadingLicense,
          ),
          SizedBox(height: layout.startupPage.welcomeLogoDistance),
          Tts(
            child: Text(
              '${t.step} 1/$pages',
              style: abiliaTextTheme.bodyMedium
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
          SizedBox(height: layout.formPadding.smallVerticalItemDistance),
          Tts(
            child: Text(
              t.setupYourInternetConnection,
              style: abiliaTextTheme.titleLarge
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
          SizedBox(height: layout.startupPage.textPickDistance),
          SizedBox(
            width: layout.startupPage.contentWidth,
            child: const WiFiPickField(),
          ),
          if (startUpState is LoadingLicenseFailed &&
              connectivityState.isConnected) ...[
            SizedBox(height: layout.formPadding.smallVerticalItemDistance),
            GestureDetector(
              onTap: context.read<StartupCubit>().checkConnectedLicense,
              child: SizedBox(
                width: layout.startupPage.contentWidth,
                child: Text(
                  t.wifiNoInternet,
                  style: abiliaTextTheme.bodyMedium
                      ?.copyWith(color: AbiliaColors.red),
                ),
              ),
            )
          ],
          SizedBox(height: layout.startupPage.textPickDistance),
          if (startUpState is LicenseLoaded && connectivityState.isConnected)
            SizedBox(
              width: layout.startupPage.contentWidth,
              child: Tts.data(
                data: t.next,
                child: TextButton(
                  key: TestKey.nextWelcomeGuide,
                  style: textButtonStyleGreen,
                  onPressed: () {
                    pageController.nextPage(
                      duration: StartupGuidePage.pageDuration,
                      curve: StartupGuidePage.curve,
                    );
                  },
                  child: Text(
                    t.next,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
