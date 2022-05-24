import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/copied_auth_providers.dart';

class SpeechSupportSettingsPage extends StatelessWidget {
  const SpeechSupportSettingsPage({
    Key? key,
    required this.textToSpeech,
    required this.speechRate,
  }) : super(key: key);

  final bool textToSpeech;
  final double speechRate;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final locale = Translator.of(context).locale.toString();

    return WillPopScope(
      onWillPop: () async {
        _disabledIfNoDownloadedVoice(context);
        return true;
      },
      child: BlocBuilder<SpeechSettingsCubit, SpeechSettingsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AbiliaAppBar(
              title: t.textToSpeech,
              label: t.system,
              iconData: AbiliaIcons.handiAlarmVibration,
            ),
            body: DividerTheme(
              data: layout.settingsBasePage.dividerThemeData,
              child: Padding(
                padding: layout.settingsBasePage.listPadding,
                child: BlocSelector<SettingsCubit, SettingsState, bool>(
                  selector: (state) => state.textToSpeech,
                  builder: (context, textToSpeech) => Column(
                    children: [
                      const TextToSpeechSwitch()
                          .pad(layout.settingsBasePage.itemPadding),
                      if (textToSpeech) ...[
                        const Divider(),
                        Tts(
                          child: Text(t.voice),
                        ).pad(layout.settingsBasePage.itemPadding),
                        Row(
                          children: [
                            Expanded(
                              child: BlocSelector<VoicesCubit, VoicesState,
                                  List<String>>(
                                selector: (state) => state.downloading,
                                builder: (context, downloadingVoices) =>
                                    PickField(
                                  text: Text(state.voice.isEmpty
                                      ? downloadingVoices.isEmpty
                                          ? t.noVoicesInstalled
                                          : t.installingVoice
                                      : state.voice),
                                  onTap: () => _showVoicesPage(context, locale),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: layout
                                    .formPadding.largeHorizontalItemDistance,
                              ),
                              child: TtsPlayButton(
                                  tts: state.voice.isNotEmpty
                                      ? t.speechTest
                                      : ''),
                            ),
                          ],
                        ).pad(layout.settingsBasePage.itemPadding),
                        Tts(
                          child: Text(t.speechRate +
                              ' ${_speechRateToProgress(state.speechRate).round()}'),
                        ).pad(layout.settingsBasePage.itemPadding),
                        AbiliaSlider(
                          value: _speechRateToProgress(state.speechRate),
                          min: -5,
                          max: 5,
                          leading: const Icon(AbiliaIcons.fastForward),
                          onChanged: state.voice.isEmpty
                              ? null
                              : (v) => context
                                  .read<SpeechSettingsCubit>()
                                  .setSpeechRate(_progressToSpeechRate(v)),
                          divisions: 10,
                        ).pad(layout.settingsBasePage.itemPadding),
                        const Divider(),
                        SwitchField(
                          value: state.speakEveryWord,
                          child: Text(t.speakEveryWord),
                        ).pad(layout.settingsBasePage.itemPadding),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigation(
              backNavigationWidget: CancelButton(
                onPressed: () async {
                  if (!_disabledIfNoDownloadedVoice(context)) {
                    await context
                        .read<SettingsCubit>()
                        .setTextToSpeech(textToSpeech);
                    await context
                        .read<SpeechSettingsCubit>()
                        .setSpeechRate(speechRate);
                  }
                  Navigator.of(context).maybePop();
                },
              ),
              forwardNavigationWidget: OkButton(onPressed: () {
                _disabledIfNoDownloadedVoice(context);
                Navigator.of(context).maybePop();
              }),
            ),
          );
        },
      ),
    );
  }

  bool _disabledIfNoDownloadedVoice(BuildContext context) {
    if (context.read<VoicesCubit>().state.downloaded.isEmpty) {
      context.read<SpeechSettingsCubit>().setVoice('');
      context.read<SettingsCubit>().setTextToSpeech(false);
      return true;
    }
    return false;
  }

  double _speechRateToProgress(double speechRate) {
    return ((speechRate - 100) / 10);
  }

  double _progressToSpeechRate(double progress) {
    return 100 + progress * 10;
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
