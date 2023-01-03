import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/android_intents.dart';

class StartupGuidePage extends StatelessWidget {
  const StartupGuidePage({Key? key}) : super(key: key);

  static const pageDuration = Duration(milliseconds: 500);
  static const curve = Curves.easeOutQuad;

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return BlocProvider(
      create: (context) => ConnectLicenseBloc(
        deviceRepository: context.read<DeviceRepository>(),
      ),
      child: MaterialAppWrapper(
        home: SafeArea(
          child: Scaffold(
            body: BlocSelector<StartupCubit, StartupState, bool>(
              selector: (state) => state is NoConnectedLicense,
              builder: (context, showLicensePage) {
                final pages = showLicensePage ? 3 : 2;
                return PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    WelcomePage(pageController: pageController),
                    PageOneWifi(
                      pageController: pageController,
                      pages: pages,
                    ),
                    if (showLicensePage)
                      PageTwoConnectedLicense(
                        pageController: pageController,
                        licenseNumberController: TextEditingController(),
                      ),
                    PageTwoVoiceSupport(
                      pageController: pageController,
                      pages: pages,
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: Padding(
              padding: layout.templates.m7.copyWith(top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  AbiliaLogo(),
                  if (Config.dev) _SkipStartupGuide(),
                  IconActionButtonDark(
                    onPressed: AndroidIntents.openSettings,
                    child: Icon(AbiliaIcons.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipStartupGuide extends StatelessWidget {
  const _SkipStartupGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<StartupCubit>().startGuideDone(),
      child: const Text('Skip startup guide >'),
    );
  }
}
