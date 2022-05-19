import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';

class TtsPlayButton extends StatefulWidget {
  const TtsPlayButton({
    Key? key,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.tts,
  }) : super(key: key);

  final TextEditingController? controller;
  final EdgeInsets padding;
  final String? tts;

  @override
  State<TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<TtsPlayButton> {
  bool _ttsIsPlaying = false;
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ??
        TextEditingController.fromValue(
            TextEditingValue(text: widget.tts ?? ''));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.textToSpeech != current.textToSpeech,
      builder: (context, settingsState) => SizedBox(
        height: layout.actionButton.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CollapsableWidget(
              collapsed:
                  !(settingsState.textToSpeech && _controller.text.isNotEmpty),
              axis: Axis.horizontal,
              child: Padding(
                padding: widget.padding,
                child: IconActionButton(
                  key: TestKey.ttsPlayButton,
                  style: actionButtonStyleDark,
                  onPressed: () => _ttsIsPlaying ? _stop() : _play(),
                  child: Icon(
                    _ttsIsPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _play() async {
    setState(() => _ttsIsPlaying = true);
    await GetIt.I<TtsInterface>().speak(_controller.text);
    if (mounted) {
      setState(() => _ttsIsPlaying = false);
    }
  }

  Future<void> _stop() async {
    await GetIt.I<TtsInterface>().stop();
    if (mounted) {
      setState(() => _ttsIsPlaying = false);
    }
  }
}
