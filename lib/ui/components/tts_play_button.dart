import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/tts/tts_interface.dart';
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
  bool ttsIsPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.textToSpeech != current.textToSpeech,
      builder: (context, settingsState) => SizedBox(
        height: layout.actionButton.size,
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            return CollapsableWidget(
              collapsed: !(settingsState.textToSpeech &&
                  widget.controller.text.isNotEmpty),
              axis: Axis.horizontal,
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
            );
          },
        ),
      ),
    );
  }

  _play() {
    setState(() => ttsIsPlaying = true);
    GetIt.I<TtsInterface>().play(widget.controller.text).whenComplete(
      () {
        if (mounted) {
          setState(() => ttsIsPlaying = false);
        }
      },
    );
  }

  _stop() {
    GetIt.I<TtsInterface>().stop().whenComplete(
      () {
        if (mounted) {
          setState(() => ttsIsPlaying = false);
        }
      },
    );
  }
}
