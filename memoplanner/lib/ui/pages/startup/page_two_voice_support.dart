import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class PageTwoVoiceSupport extends StatelessWidget {
  const PageTwoVoiceSupport({
    required this.pageController,
    required this.pages,
    Key? key,
  }) : super(key: key);

  final PageController pageController;
  final int pages;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Padding(
      padding: layout.templates.m7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const MEMOplannerLogoHiddenBackendSwitch(),
          SizedBox(height: layout.startupPage.logoDistance),
          Tts(
            child: Text(
              '${t.step} $pages/$pages',
              style: abiliaTextTheme.bodyMedium
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
          SizedBox(height: layout.formPadding.smallVerticalItemDistance),
          Tts(
            child: Text(
              t.downloadVoiceText,
              style: abiliaTextTheme.titleLarge
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
          SizedBox(height: layout.startupPage.textPickDistance),
          SizedBox(
            width: layout.startupPage.contentWidth,
            child: Builder(builder: (context) {
              final downloadingVoices =
                  context.watch<VoicesCubit>().state.downloading.isNotEmpty;
              final voice = context.watch<SpeechSettingsCubit>().state.voice;
              final trailingText = voice.isEmpty
                  ? (downloadingVoices ? t.installing : t.notSelected)
                  : voice;
              return PickField(
                leading: const Icon(AbiliaIcons.speakText),
                text: Text(t.textToSpeech),
                trailingText: Text(
                  trailingText,
                  style: (Theme.of(context).textTheme.bodyMedium ?? bodyMedium)
                      .copyWith(
                    color:
                        voice.isEmpty ? AbiliaColors.red : AbiliaColors.green,
                  ),
                ),
                onTap: () async => await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const VoicesPage()..loadAvailableVoices(context),
                    settings: (VoicesPage).routeSetting(),
                  ),
                ),
              );
            }),
          ),
          SizedBox(
            height: layout.startupPage.textPickDistance,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: layout.startupPage.pageTwoButtonWidth,
                child: IconAndTextButton(
                  onPressed: () async => pageController.previousPage(
                    duration: StartupGuidePage.pageDuration,
                    curve: StartupGuidePage.curve,
                  ),
                  text: t.back,
                  style: textButtonStyleDarkGrey,
                  icon: AbiliaIcons.navigationPrevious,
                ),
              ),
              SizedBox(
                width: layout.formPadding.horizontalItemDistance,
              ),
              SizedBox(
                width: layout.startupPage.pageTwoButtonWidth,
                child: IconAndTextButton(
                  key: TestKey.finishWelcomeGuide,
                  onPressed: () async =>
                      context.read<StartupCubit>().startGuideDone(),
                  text: t.finish,
                  icon: AbiliaIcons.ok,
                  style: textButtonStyleGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
