import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TtsPlayButton extends StatefulWidget {
  const TtsPlayButton({
    Key? key,
    required this.controller,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final TextEditingController controller;
  final EdgeInsets padding;

  @override
  State<TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<TtsPlayButton> {
  @override
  void initState() {
    super.initState();
    textIsEmpty = widget.controller.text.isEmpty;
    widget.controller.addListener(_visibilityListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_visibilityListener);
    super.dispose();
  }

  void _visibilityListener() {
    if (widget.controller.text.isEmpty != textIsEmpty) {
      if (mounted) {
        setState(() {
          textIsEmpty = widget.controller.text.isEmpty;
        });
      }
    }
  }

  bool ttsIsPlaying = false;
  late bool textIsEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.textToSpeech != current.textToSpeech,
      builder: (context, settingsState) => SizedBox(
        height: layout.actionButton.size,
        child: CollapsableWidget(
          collapsed: !(settingsState.textToSpeech &&
              widget.controller.text.isNotEmpty),
          axis: Axis.horizontal,
          child: Padding(
            padding: widget.padding,
            child: IconActionButton(
              key: TestKey.ttsPlayButton,
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
              style: actionButtonStyleDark,
            ),
          ),
        ),
      ),
    );
  }

  _play() {
    setState(() => ttsIsPlaying = true);
    GetIt.I<FlutterTts>().speak(widget.controller.text).whenComplete(() {
      if (mounted) {
        setState(() => ttsIsPlaying = false);
      }
    });
  }

  _stop() {
    GetIt.I<FlutterTts>().stop().whenComplete(() {
      if (mounted) {
        setState(() => ttsIsPlaying = false);
      }
    });
  }
}
