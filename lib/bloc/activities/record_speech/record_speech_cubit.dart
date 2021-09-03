import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:seagull/models/all.dart';
import 'package:uuid/uuid.dart';

part 'record_speech_state.dart';

const SOUND_EXTENSION = 'm4a', SOUND_NAME_PREAMBLE = 'voice_recording_';

class RecordSpeechCubit extends Cubit<RecordSpeechState> {
  RecordSpeechCubit({
    required this.onSoundRecorded,
    required this.recordedFile,
  }) : super(
          RecordSpeechState(
            recordedFile.isEmpty
                ? RecordState.StoppedNotEmpty
                : RecordState.StoppedEmpty,
          ),
        );

  final _audioPlayer = AudioPlayer();
  final _recorder = Record();
  final MAX_DURATION = 30.0;
  final void Function(AbiliaFile value) onSoundRecorded;
  double soundDuration = 30.0;

  Timer? _recordTimer;
  double progress = 0.0;
  AbiliaFile recordedFile;

  Future<void> startRecording() async {
    var result = await _recorder.hasPermission();
    if (result) {
      var tempDir = await getApplicationDocumentsDirectory();
      var tempPath = tempDir.path;
      var fileName = SOUND_NAME_PREAMBLE + Uuid().v4();
      soundDuration = MAX_DURATION;
      progress = 0.0;
      await _recorder.start(path: '$tempPath/$fileName.$SOUND_EXTENSION');
      _startTimer(soundDuration);
      emit(RecordSpeechState(RecordState.Recording));
    }
  }

  Future<void> stopRecording() async {
    final recordedFilePath = await _recorder.stop();

    if (recordedFilePath != null) {
      final uri = Uri.tryParse(recordedFilePath);
      if (uri != null) {
        final file = File.fromUri(uri);
        onSoundRecorded(
          UnstoredAbiliaFile.newFile(file),
        );
      }
      _stopTimer();
      soundDuration = progress;
      emit(RecordSpeechState(RecordState.StoppedNotEmpty));
    }
  }

  Future<void> deleteRecording() async {
    var f = File(recordedFile.path);
    await f.delete();
    progress = 0.0;
    recordedFile = AbiliaFile.empty;
    emit(RecordSpeechState(RecordState.StoppedEmpty));
  }

  Future<void> playRecording() async {
    progress = 0.0;
    await _audioPlayer.play(recordedFile.path);
    _startTimer(soundDuration);
    emit(RecordSpeechState(RecordState.Playing));
  }

  Future<void> stopPlaying() async {
    _stopTimer();
    emit(RecordSpeechState(RecordState.StoppedNotEmpty));
  }

  void _startTimer(double maxDuration) {
    _recordTimer =
        Timer.periodic(Duration(milliseconds: 100), (Timer recordTimer) {
      progress += 0.1;
      if (progress > maxDuration) {
        stopRecording();
        recordTimer.cancel();
        return;
      } else {
        state.state == RecordState.Recording
            ? emit(RecordSpeechState(RecordState.Recording2))
            : emit(RecordSpeechState(RecordState.Recording));
        return;
      }
    });
  }

  void _stopTimer() {
    _recordTimer?.cancel();
  }
}
