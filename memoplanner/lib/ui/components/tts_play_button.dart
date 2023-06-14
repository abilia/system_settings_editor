import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:text_to_speech/text_to_speech.dart';

class TtsPlayButton extends StatelessWidget {
  final TextEditingController? controller;
  final EdgeInsets padding;
  final String tts;
  final bool transparent;

  const TtsPlayButton({
    this.controller,
    this.padding = EdgeInsets.zero,
    this.tts = '',
    this.transparent = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) => _TtsPlayButton(
          text: controller.text,
          padding: padding,
          transparent: transparent,
        ),
      );
    } else {
      return _TtsPlayButton(
        text: tts,
        padding: padding,
        transparent: transparent,
      );
    }
  }
}

class _TtsPlayButton extends StatefulWidget {
  final String text;
  final EdgeInsets padding;
  final bool transparent;

  const _TtsPlayButton({
    required this.text,
    required this.transparent,
    required this.padding,
  });

  @override
  State<_TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<_TtsPlayButton> {
  bool ttsIsPlaying = false;

  @override
  Widget build(BuildContext context) {
    final textToSpeech =
        context.select((SpeechSettingsCubit cubit) => cubit.state.textToSpeech);
    return SizedBox(
      height: layout.actionButton.smallSize,
      child: CollapsableWidget(
        collapsed: !(textToSpeech && widget.text.isNotEmpty),
        axis: Axis.horizontal,
        child: Padding(
          padding: widget.padding,
          child: IconActionButton(
            key: TestKey.ttsPlayButton,
            style: widget.transparent
                ? actionButtonStyleDark
                : actionButtonStyleNoneTransparentDark,
            onPressed: () async => ttsIsPlaying ? _stop() : _play(),
            child: Icon(
              ttsIsPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _play() async {
    setState(() => ttsIsPlaying = true);
    await GetIt.I<TtsHandler>().speak(widget.text);
    if (mounted) {
      setState(() => ttsIsPlaying = false);
    }
  }

  Future<void> _stop() async {
    await GetIt.I<TtsHandler>().stop();
    if (mounted) {
      setState(() => ttsIsPlaying = false);
    }
  }
}
