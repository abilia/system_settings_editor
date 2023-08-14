import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/models/all.dart';
import 'package:record/record.dart';

part 'record_sound_state.dart';

class AudioTicker {
  final int millisecondTickRate;
  const AudioTicker(this.millisecondTickRate);

  Stream<int> tick({required int duration}) {
    return Stream.periodic(Duration(milliseconds: millisecondTickRate),
            (x) => x * millisecondTickRate)
        .take((duration ~/ millisecondTickRate) + 1);
  }
}

class RecordSoundCubit extends Cubit<RecordSoundState> {
  static const maxRecordingTime = Duration(seconds: 30);
  final Record _recorder;
  StreamSubscription<Duration>? _tickerSubscription;
  StreamSubscription<Duration>? onDurationChanged;
  final AudioTicker _ticker = const AudioTicker(50);
  final AudioPlayer audioPlayer;

  RecordSoundCubit({
    required this.audioPlayer,
    required AbiliaFile originalSoundFile,
    Record? record,
  })  : _recorder = record ?? Record(),
        super(
          originalSoundFile.isEmpty
              ? const EmptyRecordSoundState()
              : UnchangedRecordingSoundState(originalSoundFile, Duration.zero),
        );

  Future<void> setFile(File? file) async {
    if (file != null) {
      onDurationChanged = audioPlayer.onDurationChanged.listen((event) {
        final s = state;
        if (s is UnchangedRecordingSoundState) {
          emit(UnchangedRecordingSoundState(s.recordedFile, event));
        }
      });
      return audioPlayer.setSource(DeviceFileSource(file.path));
    }
  }

  Future<void> startRecording() async {
    await _recorder.start();
    _tickerSubscription = _ticker
        .tick(duration: maxRecordingTime.inMilliseconds)
        .map((event) => Duration(milliseconds: event))
        .listen((duration) => _ticking(duration));
    emit(const RecordingSoundState(Duration.zero));
  }

  Future<void> _ticking(Duration duration) async {
    if (isClosed) return;
    if (duration >= maxRecordingTime) {
      emit(const RecordingSoundState(maxRecordingTime));
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
        emit(NewRecordedSoundState(recordedFile, state.duration));
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
    emit(const EmptyRecordSoundState());
  }

  @override
  Future<void> close() async {
    await super.close();
    await _tickerSubscription?.cancel();
    await onDurationChanged?.cancel();
  }
}
