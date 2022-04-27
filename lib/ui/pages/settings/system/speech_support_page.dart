import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';

class SpeechSupportPage extends StatelessWidget {
  const SpeechSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final defaultPadding = layout.speechSupportPage.defaultPadding;
    final topPadding = layout.speechSupportPage.topPadding;
    final bottomPadding = layout.speechSupportPage.bottomPadding;
    final dividerPadding = layout.speechSupportPage.dividerPadding;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AbiliaAppBar(
            title: t.textToSpeech,
            label: t.system,
            iconData: AbiliaIcons.handiAlarmVibration,
          ),
          body: ListView(
            children: [
              const TextToSpeechSwitch().pad(topPadding),
              const Divider().pad(dividerPadding),
              Expanded(
                child: SwitchField(
                  value: state.speakEveryWord,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().setTextToSpeech(v),
                  child: Text(t.speakEveryWord),
                ),
              ).pad(defaultPadding),
              const Divider().pad(dividerPadding),
              Tts(child: Text(t.speechRate + ' ${state.speechRate}')).pad(defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: AbiliaSlider(
                      value: state.speechRate.toDouble() / 100,
                      leading: const Icon(AbiliaIcons.fastForward),
                      onChanged: (v) =>
                          context.read<SettingsCubit>().setSpeechRate(v * 100),
                    ),
                  ),
                  const TtsPlayButton().pad(layout.speechSupportPage.buttonPadding),
                ],
              ).pad(defaultPadding),
              Tts(child: Text(t.voice)).pad(defaultPadding),
              PickField(
                text: Text(state.voice),
              ).pad(bottomPadding),
            ],
          ),
        );
      },
    );
  }
}

class TtsPlayButton extends StatefulWidget {
  const TtsPlayButton({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  State<TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<TtsPlayButton> {
  bool ttsIsPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.textToSpeech != current.textToSpeech,
      builder: (context, settingsState) => SizedBox(
        height: layout.actionButton.size,
        child: Padding(
          padding: widget.padding,
          child: IconActionButton(
            key: TestKey.ttsPlayButton,
            style: actionButtonStyleDark,
            onPressed: () async {
              if (ttsIsPlaying) {
                _stop();
              } else {
                _play();
              }
            },
            child: Icon(
              ttsIsPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
            ),
          ),
        ),
      ),
    );
  }

  _play() {
    setState(() => ttsIsPlaying = true);
    Translated t = Translator.of(context).translate;
    GetIt.I<TtsInterface>()
        .speak('${t.textToSpeech}  ${t.speechRate}')
        .whenComplete(() {
      if (mounted) {
        setState(() => ttsIsPlaying = false);
      }
    });
  }

  _stop() {
    GetIt.I<TtsInterface>().stop().whenComplete(() {
      if (mounted) {
        setState(() => ttsIsPlaying = false);
      }
    });
  }
}
