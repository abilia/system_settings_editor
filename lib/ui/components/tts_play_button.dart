import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TtsPlayButton extends StatefulWidget {
  const TtsPlayButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  State<TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<TtsPlayButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_visibilityListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_visibilityListener);
    super.dispose();
  }

  void _visibilityListener() {
    if (mounted) {
      setState(() {});
    }
  }

  bool ttsIsActive = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.textToSpeech != current.textToSpeech,
      builder: (context, settingsState) => SizedBox(
        height: layout.actionButton.size,
        child: CollapsableWidget(
          collapsed: !(settingsState.textToSpeech &&
              widget.controller.text.isNotEmpty),
          axis: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: layout.defaultTextInputPage.textFieldActionButtonSpacing,
              ),
              IconActionButton(
                key: TestKey.ttsPlayButton,
                onPressed: () async {
                  if (ttsIsActive) {
                    GetIt.I<FlutterTts>().stop().whenComplete(() {
                      if (mounted) {
                        setState(() => ttsIsActive = false);
                      }
                    });
                  } else {
                    setState(() => ttsIsActive = true);
                    GetIt.I<FlutterTts>()
                        .speak(widget.controller.text)
                        .whenComplete(() {
                      if (mounted) {
                        setState(() => ttsIsActive = false);
                      }
                    });
                  }
                },
                child: Icon(
                  ttsIsActive ? AbiliaIcons.stop : AbiliaIcons.playSound,
                ),
                style: actionButtonStyleDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
