import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/activity/record_speech.dart';
import 'package:uuid/uuid.dart';

class RecordSpeechCubit extends Cubit<RecordPageState> {
  RecordSpeechCubit(
      {required this.onSoundRecorded, required this.recordedFilePath})
      : super(recordedFilePath != ''
            ? RecordPageState.StoppedNotEmpty
            : RecordPageState.StoppedEmpty);

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Record _recorder = Record();
  final MAX_DURATION = 30.0;
  final ValueChanged<String> onSoundRecorded;
  double _soundDuration = 30.0;

  // RecordPageState recordState = RecordPageState.StoppedEmpty;
  Timer? _recordTimer;
  double _progress = 0.0;
  String recordedFilePath;

  Future<void> startRecording() async {
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
      emit(RecordPageState.Recording);
    }
  }

  Future<void> stopRecording() async {
    recordedFilePath = (await _recorder.stop())!;
    onSoundRecorded(recordedFilePath);
    _stopTimer();
    _soundDuration = _progress;
    emit(RecordPageState.StoppedNotEmpty);
  }

  Future<void> deleteRecording() async {
    var f = File(recordedFilePath);
    await f.delete();
    _progress = 0.0;
    emit(RecordPageState.StoppedEmpty);
  }

  Future<void> playRecording() async {
    _progress = 0.0;
    await _audioPlayer.play(recordedFilePath);
    _startTimer(_soundDuration);
  }

  Future<void> stopPlaying() async {
    _stopTimer();
    emit(RecordPageState.StoppedNotEmpty);
  }

  void _startTimer(double maxDuration) {
    _recordTimer =
        Timer.periodic(Duration(milliseconds: 100), (Timer recordTimer) {
      _progress += 0.1;
      if (_progress > maxDuration) {
        stopRecording();
        recordTimer.cancel();
        return;
      } else {
        emit(state);
      }
    });
  }

  void _stopTimer() {
    _recordTimer?.cancel();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
  }
}
