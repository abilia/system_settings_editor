import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
              onTap: () => _showVoicesPage(context),
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

  void _showVoicesPage(BuildContext context) async {
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
