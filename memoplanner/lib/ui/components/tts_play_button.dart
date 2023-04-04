import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:memoplanner/ui/all.dart';

class TtsPlayButton extends StatelessWidget {
  const TtsPlayButton({
    Key? key,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.tts = '',
    this.buttonStyle,
  }) : super(key: key);
  final TextEditingController? controller;
  final EdgeInsets padding;
  final String tts;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) => _TtsPlayButton(
          text: controller.text,
          padding: padding,
          buttonStyle: buttonStyle,
        ),
      );
    } else {
      return _TtsPlayButton(
        text: tts,
        padding: padding,
        buttonStyle: buttonStyle,
      );
    }
  }
}

class _TtsPlayButton extends StatefulWidget {
  const _TtsPlayButton({
    required this.text,
    this.padding = EdgeInsets.zero,
    this.buttonStyle,
    Key? key,
  }) : super(key: key);

  final String text;
  final EdgeInsets padding;
  final ButtonStyle? buttonStyle;

  @override
  State<_TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<_TtsPlayButton> {
  bool ttsIsPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SpeechSettingsCubit, SpeechSettingsState, bool>(
      selector: (state) => state.textToSpeech,
      builder: (context, textToSpeech) => SizedBox(
        height: layout.actionButton.size,
        child: CollapsableWidget(
          collapsed: !(textToSpeech && widget.text.isNotEmpty),
          axis: Axis.horizontal,
          child: Padding(
            padding: widget.padding,
            child: IconActionButton(
              key: TestKey.ttsPlayButton,
              style: widget.buttonStyle ?? actionButtonStyleDark,
              onPressed: () async => ttsIsPlaying ? _stop() : _play(),
              child: Icon(
                ttsIsPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _play() async {
    setState(() => ttsIsPlaying = true);
    await GetIt.I<TtsInterface>().speak(widget.text);
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
