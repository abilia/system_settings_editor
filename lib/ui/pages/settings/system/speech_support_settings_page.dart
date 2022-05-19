import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/copied_auth_providers.dart';

class SpeechSupportSettingsPage extends StatelessWidget {
  const SpeechSupportSettingsPage(
      {Key? key,
      required this.textToSpeech,
      required this.speechRate,
      required this.voice})
      : super(key: key);

  final bool textToSpeech;
  final double speechRate;
  final String voice;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final locale = Translator.of(context).locale.toString();

    return BlocBuilder<SpeechSettingsCubit, SpeechSettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AbiliaAppBar(
            title: t.textToSpeech,
            label: t.system,
            iconData: AbiliaIcons.handiAlarmVibration,
          ),
          body: BlocSelector<SettingsCubit, SettingsState, bool>(
            selector: (state) => state.textToSpeech,
            builder: (context, textToSpeech) {
              return BlocSelector<VoicesCubit, VoicesState, List<String>>(
                  selector: (state) => state.downloadingVoices,
                  builder: (context, downloadingVoices) {
                    return BlocListener<VoicesCubit, VoicesState>(
                      listener: (context, voicesState) async {
                        await context
                            .read<SpeechSettingsCubit>()
                            .setVoice(voice);
                      },
                      child: DividerTheme(
                        data: layout.settingsBasePage.dividerThemeData,
                        child: Padding(
                          padding: layout.settingsBasePage.listPadding,
                          child: Column(
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
                                      child: PickField(
                                        text: Text(state.voice.isEmpty
                                            ? downloadingVoices.isEmpty
                                                ? t.noVoicesInstalled
                                                : t.installingVoice
                                            : state.voice),
                                        onTap: () => _pushVoicesPage(
                                            context, locale, state.voice),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: layout.formPadding
                                            .largeHorizontalItemDistance,
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
                                  value:
                                      _speechRateToProgress(state.speechRate),
                                  min: -5,
                                  max: 5,
                                  leading: const Icon(AbiliaIcons.fastForward),
                                  onChanged: state.voice.isEmpty
                                      ? null
                                      : (v) => context
                                          .read<SpeechSettingsCubit>()
                                          .setSpeechRate(
                                              _progressToSpeechRate(v)),
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
                    );
                  });
            },
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(
              onPressed: () async {
                await context
                    .read<SettingsCubit>()
                    .setTextToSpeech(textToSpeech);
                await context
                    .read<SpeechSettingsCubit>()
                    .setSpeechRate(speechRate);
                Navigator.of(context).maybePop();
              },
            ),
            forwardNavigationWidget: OkButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
        );
      },
    );
  }

  double _speechRateToProgress(double speechRate) {
    return ((speechRate - 100) / 10);
  }

  double _progressToSpeechRate(double progress) {
    return 100 + progress * 10;
  }

  void _pushVoicesPage(
      BuildContext context, String locale, String voice) async {
    final authProviders = copiedAuthProviders(context);

    final selectedVoice = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: VoicesPage(initialSelection: voice),
        ),
      ),
    );
    if (selectedVoice != null) {
      context.read<SpeechSettingsCubit>().setVoice(selectedVoice);
      // context.read<SettingsCubit>().setTextToSpeech(true);
    }
  }
}
