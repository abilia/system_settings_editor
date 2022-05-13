import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';

class SpeechSupportSettingsPage extends StatelessWidget {
  const SpeechSupportSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final locale = Translator.of(context).locale.toString();
    final defaultPadding = layout.speechSupportPage.defaultPadding;
    final topPadding = layout.speechSupportPage.topPadding;
    final bottomPadding = layout.speechSupportPage.bottomPadding;
    final dividerPadding = layout.speechSupportPage.dividerPadding;

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
              return ListView(
                children: [
                  TextToSpeechSwitch(
                    immediate: false,
                    onChanged: !textToSpeech && state.voice.isEmpty
                        ? (v) => pushVoicesPage(context, locale, state.voice)
                        : null,
                  ).pad(topPadding),
                  if (textToSpeech) ...[
                    const Divider().pad(dividerPadding),
                    SwitchField(
                      value: state.speakEveryWord,
                      child: Text(t.speakEveryWord),
                    ).pad(defaultPadding),
                    const Divider().pad(dividerPadding),
                    Tts(
                      child:
                          Text(t.speechRate + ' ${state.speechRate.toInt()}'),
                    ).pad(defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: AbiliaSlider(
                            value: state.speechRate / 100,
                            leading: const Icon(AbiliaIcons.fastForward),
                            onChanged: (v) {
                              context
                                  .read<SpeechSettingsCubit>()
                                  .setSpeechRate(v * 100);
                            },
                          ),
                        ),
                        const TtsTestButton()
                            .pad(layout.speechSupportPage.buttonPadding),
                      ],
                    ).pad(defaultPadding),
                    Tts(child: Text(t.voice)).pad(defaultPadding),
                    PickField(
                      text: Text(state.voice),
                      onTap: () => pushVoicesPage(context, locale, state.voice),
                    ).pad(bottomPadding),
                  ],
                ],
              );
            },
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(
              onPressed: () {
                context.read<SettingsCubit>().reset();
                context.read<SpeechSettingsCubit>().reset();
                Navigator.of(context).maybePop();
              },
            ),
            forwardNavigationWidget: OkButton(
              onPressed: () {
                context.read<SpeechSettingsCubit>().save();
                context.read<SettingsCubit>().save();
                Navigator.of(context).maybePop();
              },
            ),
          ),
        );
      },
    );
  }

  void pushVoicesPage(BuildContext context, String locale, String voice) async {
    final selectedVoice = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => BlocProvider<VoicesCubit>(
          create: (context) =>
              VoicesCubit(GetIt.I<BaseClient>(), locale, voice),
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
    await GetIt.I<TtsInterface>().speak('${t.textToSpeech}  ${t.speechRate}');
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
