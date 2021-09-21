import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:seagull/models/all.dart';

part 'record_sound_state.dart';

class AudioTicker {
  final int millisTickRate;
  const AudioTicker(this.millisTickRate);

  Stream<int> tick({required int duration}) {
    return Stream.periodic(
            Duration(milliseconds: millisTickRate), (x) => x * millisTickRate)
        .take(duration ~/ millisTickRate);
  }
}

class RecordSoundCubit extends Cubit<RecordSoundState> {
  static const maxRecordingTime = Duration(seconds: 30);
  final Record _recorder;
  StreamSubscription<Duration>? _tickerSubscription;
  final AudioTicker _ticker = AudioTicker(50);

  RecordSoundCubit({required AbiliaFile originalSoundFile, Record? record})
      : _recorder = record ?? Record(),
        super(
          originalSoundFile.isEmpty
              ? EmptyRecordSoundState()
              : UnchangedRecordingSoundState(originalSoundFile),
        );

  Future<void> startRecording() async {
    bool hasPermission = await _recorder.hasPermission();
    if (hasPermission) {
      await _recorder.start();
      _tickerSubscription = _ticker
          .tick(duration: maxRecordingTime.inMilliseconds)
          .map((event) => Duration(milliseconds: event))
          .listen((duration) => _ticking(duration));
      emit(RecordingSoundState(Duration.zero));
    }
  }

  void _ticking(Duration duration) async {
    if (duration >= maxRecordingTime) {
      await stopRecording();
    } else {
      emit(RecordingSoundState(duration));
    }
  }

  Future<void> stopRecording() async {
    final recordedFilePath = await _recorder.stop();
    if (recordedFilePath != null) {
      final uri = Uri.tryParse(recordedFilePath);
      if (uri != null) {
        final file = File.fromUri(uri);
        final recordedFile = UnstoredAbiliaFile.newFile(file);
        emit(NewRecordedSoundState(recordedFile));
      }
    }
    await _tickerSubscription?.cancel();
  }

  Future<void> deleteRecording() async {
    final s = state;
    if (s is NewRecordedSoundState &&
        await s.unstoredAbiliaFile.file.exists()) {
      await s.unstoredAbiliaFile.file.delete();
    }
    emit(EmptyRecordSoundState());
  }

  @override
  Future<void> close() async {
    await super.close();
    await _tickerSubscription?.cancel();
  }
}
