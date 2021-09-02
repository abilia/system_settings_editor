import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

final String SOUND_EXTENSION = 'm4a';
final String SOUND_NAME_PREAMBLE = 'voice_recording_';

class RecordingWidget extends StatefulWidget {
  final String originalSoundFile;
  final ValueChanged<String> onSoundRecorded;
  final RecordPageState state;

  const RecordingWidget({
    required this.state,
    required this.originalSoundFile,
    required this.onSoundRecorded,
  });

  @override
  State<StatefulWidget> createState() {
    return _RecordingWidgetState(
        onSoundRecorded: onSoundRecorded, state: state);
  }
}

class _RecordingWidgetState extends State<RecordingWidget> {
  final MAX_DURATION = 30.0;
  final ValueChanged<String> onSoundRecorded;
  double _soundDuration = 30.0;
  RecordPageState state;
  double _progress = 0.0;

  _RecordingWidgetState({required this.onSoundRecorded, required this.state}) {
    ;
  }

  @override
  Widget build(BuildContext context) {
    var actionRowState = ActionRowProvider(state: state);
    var progressIndicator = _progress / _soundDuration;
    return BlocListener<RecordSpeechCubit, RecordPageState>(
      listener: (context, state) {
        setState(() {
          print('state ' + state.toString());
          this.state = state;
          _progress = context.read<RecordSpeechCubit>().progress;
          _soundDuration = context.read<RecordSpeechCubit>().soundDuration;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TimeDisplay(timeElapsed: _progress),
          _TimeProgressIndicator(
              progressIndicator, AlwaysStoppedAnimation(Colors.red)),
          SizedBox(height: 24.0.s),
          actionRowState,
        ],
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final double timeElapsed;
  final double millisPerSecond = 1000.0;

  _TimeDisplay({this.timeElapsed = 0.0});

  @override
  Widget build(BuildContext context) {
    var seconds = timeElapsed.floor();
    var milliseconds = ((timeElapsed - seconds) * millisPerSecond).floor();
    final duration = Duration(seconds: seconds, milliseconds: milliseconds);
    var timeText = _formatTime(duration);
    final translator = Translator.of(context).translate;
    return (Container(
      width: 120.s,
      height: 120.s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translator.duration,
            textAlign: TextAlign.left,
          ),
          TextField(
            readOnly: true,
            enabled: true,
            keyboardType: TextInputType.number,
            showCursor: false,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(labelText: timeText),
          ),
          SizedBox(height: 8.0.s),
        ],
      ),
    ));
  }

  String _formatTime(Duration d) {
    return d.toString().substring(5, 10).replaceAll('.', ':');
  }
}

class _TimeProgressIndicator extends LinearProgressIndicator {
  const _TimeProgressIndicator(double value, Animation<Color> anim)
      : super(
            value: value,
            backgroundColor: Colors.grey,
            valueColor: anim,
            minHeight: 6);
}

class ActionRowProvider extends StatelessWidget {
  final RecordPageState state;

  const ActionRowProvider({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case RecordPageState.StoppedNotEmpty:
        return StoppedNotEmptyState();
      case RecordPageState.StoppedEmpty:
        return StoppedEmptyState();
      case RecordPageState.Playing:
        return PlayingState();
      case RecordPageState.Recording:
      case RecordPageState.Recording2:
        return RecordingState();
      default:
        return StoppedEmptyState();
    }
  }
}

class PlayingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StopButton(onPressed: () {
          context.read<RecordSpeechCubit>().stopPlaying();
        })
      ],
    );
  }
}

class RecordingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordSpeechCubit, RecordPageState>(
        builder: (context, state) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: StopButton(
                onPressed: () {
                  context.read<RecordSpeechCubit>().stopRecording();
                },
              ),
            ),
          ]);
    });
  }
}

class StoppedEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordSpeechCubit, RecordPageState>(
        builder: (context, state) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RecordAudioButton(
              onPressed: () {
                context.read<RecordSpeechCubit>().startRecording();
              },
            ),
          ),
        ],
      );
    });
  }
}

class StoppedNotEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordSpeechCubit, RecordPageState>(
        builder: (context, state) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PlaySpeechButton(
              onPressed: () {
                context.read<RecordSpeechCubit>().playRecording();
              },
            ),
          ),
          ActionButton(
              onPressed: () {
                context.read<RecordSpeechCubit>().deleteRecording();
              },
              child: Icon(AbiliaIcons.delete_all_clear))
        ],
      );
    });
  }
}
