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
          MEMOplannerLogo(height: layout.login.logoHeight),
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
            width: layout.startupPageLayout.contentWidth,
            child: BlocBuilder<SpeechSettingsCubit, SpeechSettingsState>(
              builder: (context, state) => PickField(
                leading: const Icon(AbiliaIcons.speakText),
                text: Text(t.textToSpeech),
                trailingText: Text(
                  state.voice.isEmpty ? t.notSelected : state.voice,
                  style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                      .copyWith(
                    color: state.voice.isEmpty
                        ? AbiliaColors.red
                        : AbiliaColors.green,
                  ),
                ),
                onTap: () async => await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VoicesPage(),
                  ),
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
                width: layout.startupPageLayout.pageTwoButtonWidth,
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
                width: layout.startupPageLayout.pageTwoButtonWidth,
                child: IconAndTextButton(
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
