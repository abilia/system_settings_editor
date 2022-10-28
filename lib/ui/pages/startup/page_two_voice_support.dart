import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PageTwoVoiceSupport extends StatelessWidget {
  const PageTwoVoiceSupport({
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
          MEMOplannerLogo(height: layout.login.logoHeight),
          SizedBox(height: layout.startupPage.logoDistance),
          Tts(
            child: Text(
              '${t.step} 2/2',
              style: abiliaTextTheme.bodyText2
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
          SizedBox(height: layout.formPadding.smallVerticalItemDistance),
          Tts(
            child: Text(
              t.downloadVoiceText,
              style: abiliaTextTheme.headline6
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
                  style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                      .copyWith(
                    color:
                        voice.isEmpty ? AbiliaColors.red : AbiliaColors.green,
                  ),
                ),
                onTap: () async => await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoicesPage()),
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
                width: layout.startupPage.pageTwoButtonWidth,
                child: IconAndTextButton(
                  key: TestKey.finishWelcomeGuide,
                  onPressed: () {
                    context.read<StartupCubit>().startGuideDone();
                  },
                  text: t.finsish,
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
