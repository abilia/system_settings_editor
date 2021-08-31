import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:seagull/ui/all.dart';
import 'package:uuid/uuid.dart';

enum RecordPageState { StoppedEmpty, Recording, StoppedNotEmpty, Playing }

final String SOUND_EXTENSION = 'm4a';
final String SOUND_NAME_PREAMBLE = 'voice_recording_';

class RecordingWidget extends StatefulWidget {
  final String originalSoundFile;
  final ValueChanged<String> onSoundRecorded;

  const RecordingWidget(
      {required this.originalSoundFile, required this.onSoundRecorded});

  @override
  State<StatefulWidget> createState() {
    return _RecordingWidgetState(
        recordedFilePath: originalSoundFile, onSoundRecorded: onSoundRecorded);
  }
}

class _RecordingWidgetState extends State<RecordingWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Record _recorder = Record();
  final MAX_DURATION = 30.0;
  final ValueChanged<String> onSoundRecorded;
  double _soundDuration = 30.0;
  RecordPageState state = RecordPageState.StoppedEmpty;
  Timer? _recordTimer;
  double _progress = 0.0;
  String recordedFilePath;

  _RecordingWidgetState(
      {required this.recordedFilePath, required this.onSoundRecorded}) {
    state = recordedFilePath != ''
        ? RecordPageState.StoppedNotEmpty
        : RecordPageState.StoppedEmpty;
  }

  @override
  Widget build(BuildContext context) {
    var actionRowState = _createActionRowFromState(state);
    var progressIndicator = _progress / _soundDuration;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _TimeDisplay(timeElapsed: _progress),
        _TimeProgressIndicator(
            progressIndicator, AlwaysStoppedAnimation(Colors.red)),
        SizedBox(height: 24.0.s),
        actionRowState,
      ],
    );
  }

  void _buttonPressInChildWidget(RecordPageState newState) {
    setState(() {
      state = newState;
    });
    switch (state) {
      case RecordPageState.Recording:
        _startRecording();
        break;
      case RecordPageState.StoppedNotEmpty:
        _stopRecording();
        break;
      case RecordPageState.StoppedEmpty:
        _deleteRecording();
        break;
      case RecordPageState.Playing:
        _playSound();
        break;
      default:
        break;
    }
  }

  StatelessWidget _createActionRowFromState(RecordPageState state) {
    switch (state) {
      case RecordPageState.StoppedNotEmpty:
        return StoppedState(
            soundExists: true, notifyParent: _buttonPressInChildWidget);
      case RecordPageState.StoppedEmpty:
        return StoppedState(
            soundExists: false, notifyParent: _buttonPressInChildWidget);
      case RecordPageState.Playing:
        return PlayingState(notifyParent: _buttonPressInChildWidget);
      case RecordPageState.Recording:
        return RecordingState(buttonPressCallback: _buttonPressInChildWidget);
    }
  }

  Future<void> _startRecording() async {
    var result = await _recorder.hasPermission();
    if (result) {
      var tempDir = await getApplicationDocumentsDirectory();
      var tempPath = tempDir.path;
      var fileName = SOUND_NAME_PREAMBLE + Uuid().v4();
      _soundDuration = MAX_DURATION;
      _progress = 0.0;
      await _recorder.start(
        path: '$tempPath/$fileName.$SOUND_EXTENSION', // required
        encoder: AudioEncoder.AAC, // by default
        bitRate: 128000, // by default
      );
      _startTimer(_soundDuration);
    }
  }

  Future<void> _stopRecording() async {
    recordedFilePath = (await _recorder.stop())!;
    onSoundRecorded(recordedFilePath);
    _stopTimer();
    _soundDuration = _progress;
    setState(() {
      state = RecordPageState.StoppedNotEmpty;
    });
  }

  Future<void> _deleteRecording() async {
    var f = File(recordedFilePath);
    await f.delete();
    _progress = 0.0;
  }

  Future<void> _playSound() async {
    _progress = 0.0;
    await _audioPlayer.play(recordedFilePath);
    _startTimer(_soundDuration);
  }

  void _startTimer(double maxDuration) {
    _recordTimer =
        Timer.periodic(Duration(milliseconds: 100), (Timer recordTimer) {
          setState(() {
            _progress += 0.1;
            if (_progress > maxDuration) {
              _stopRecording();
              recordTimer.cancel();
              return;
            }
          });
        });
  }

  void _stopTimer() {
    _recordTimer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _recordTimer?.cancel();
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

class PlayingState extends StatelessWidget {
  final ValueChanged<RecordPageState> notifyParent;

  PlayingState({required this.notifyParent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StopButton(onPressed: () {
          notifyParent(RecordPageState.StoppedNotEmpty);
        })
      ],
    );
  }
}

class RecordingState extends StatelessWidget {
  final ValueChanged<RecordPageState> buttonPressCallback;

  RecordingState({required this.buttonPressCallback});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: StopButton(onPressed: () {
            buttonPressCallback(RecordPageState.StoppedNotEmpty);
          }),
        ),
      ],
    );
  }
}

class StoppedState extends StatelessWidget {
  final ValueChanged<RecordPageState> notifyParent;
  final bool soundExists;

  StoppedState({required this.soundExists, required this.notifyParent});

  @override
  Widget build(BuildContext context) {
    if (soundExists) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PlaySpeechButton(onPressed: () {
              notifyParent(RecordPageState.Playing);
            }),
          ),
          ActionButton(
              onPressed: () {
                notifyParent(RecordPageState.StoppedEmpty);
              },
              child: Icon(AbiliaIcons.delete_all_clear))
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RecordAudioButton(onPressed: () {
              notifyParent(RecordPageState.Recording);
            }),
          ),
        ],
      );
    }
  }
}
