import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/copied_auth_providers.dart';

class SpeechSupportSettingsPage extends StatelessWidget {
  const SpeechSupportSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final locale = Translator.of(context).locale.toString();
    bool textToSpeech = context.read<SettingsCubit>().state.textToSpeech;
    double speechRate = context.read<SpeechSettingsCubit>().state.speechRate;
    String voice = context.read<SpeechSettingsCubit>().state.voice;

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
              return BlocSelector<VoicesCubit, VoicesState, String>(
                  selector: (state) => state.downloadingVoice,
                  builder: (context, downloadingVoice) {
                    return BlocListener<VoicesCubit, VoicesState>(
                      listener: (context, voicesState) async {
                        voice = voicesState.selectedVoice;
                        await context
                            .read<SpeechSettingsCubit>()
                            .setVoice(voice);
                      },
                      child: DividerTheme(
                        data: layout.settingsBasePage.dividerThemeData,
                        child: Padding(
                          padding: layout.settingsBasePage.listPadding,
                          child: ListView(
                            children: [
                              TextToSpeechSwitch(
                                onChanged: !textToSpeech && state.voice.isEmpty
                                    ? (v) => pushVoicesPage(
                                        context, locale, state.voice)
                                    : null,
                              ).pad(layout.settingsBasePage.itemPadding),
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
                                            ? downloadingVoice.isEmpty
                                                ? t.noVoicesInstalled
                                                : t.installingVoice
                                            : state.voice),
                                        onTap: () => pushVoicesPage(
                                            context, locale, state.voice),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: layout.formPadding
                                            .largeHorizontalItemDistance,
                                      ),
                                      child: const TtsTestButton(),
                                    ),
                                  ],
                                ).pad(layout.settingsBasePage.itemPadding),
                                Tts(
                                  child: Text(t.speechRate +
                                      ' ${state.speechRate.toInt()}'),
                                ).pad(layout.settingsBasePage.itemPadding),
                                AbiliaSlider(
                                  value: state.speechRate,
                                  min: 50,
                                  max: 150,
                                  leading: const Icon(AbiliaIcons.fastForward),
                                  onChanged: (v) {
                                    context
                                        .read<SpeechSettingsCubit>()
                                        .setSpeechRate(v);
                                  },
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
                await context.read<SpeechSettingsCubit>().setVoice(voice);
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

  void pushVoicesPage(BuildContext context, String locale, String voice) async {
    final authProviders = copiedAuthProviders(context);

    final selectedVoice = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: VoicesPage(initialSelection: voice),
        ),
        settings:
            RouteSettings(name: Translator.of(context).translate.textToSpeech),
      ),
    );
    if (selectedVoice != null) {
      context.read<SpeechSettingsCubit>().setVoice(selectedVoice);
      context.read<SettingsCubit>().setTextToSpeech(true);
    }
  }
}

@visibleForTesting
class TtsTestButton extends StatefulWidget {
  const TtsTestButton({
    Key? key,
  }) : super(key: key);

  @override
  State<TtsTestButton> createState() => _TtsTestButtonState();
}

class _TtsTestButtonState extends State<TtsTestButton> {
  bool ttsIsPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.textToSpeech != current.textToSpeech,
      builder: (context, settingsState) => SizedBox(
        height: layout.actionButton.size,
        child: IconActionButton(
          style: actionButtonStyleDark,
          onPressed: () => ttsIsPlaying ? _stop() : _play(),
          child: Icon(
            ttsIsPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
          ),
        ),
      ),
    );
  }

  Future<void> _play() async {
    setState(() => ttsIsPlaying = true);
    Translated t = Translator.of(context).translate;
    await GetIt.I<TtsInterface>().speak(t.speechTest);
    if (mounted) {
      setState(() => ttsIsPlaying = false);
    }
  }

  Future<void> _stop() async {
    await GetIt.I<TtsInterface>().stop();
    if (mounted) {
      setState(() => ttsIsPlaying = false);
    }
  }
}
