import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:seagull/models/abilia_file.dart';
import 'package:seagull/models/all.dart';
import 'package:uuid/uuid.dart';

part 'record_sound_state.dart';

class RecordSoundCubit extends Cubit<RecordSoundState> {
  final _recorder = Record();
  final AbiliaFile originalSoundFile;
  AbiliaFile recordedFile = AbiliaFile.empty;

  RecordSoundCubit({
    required this.originalSoundFile,
  }) : super(
          StoppedSoundState(originalSoundFile),
        ) {
    recordedFile = originalSoundFile;
  }

  Future<void> startRecording() async {
    var tempDir = await getApplicationDocumentsDirectory();
    var tempPath = tempDir.path;
    await _recorder.start(path: '$tempPath/' + Uuid().v4() + '.mp3');
    emit(RecordingSoundState(AbiliaFile.empty));
  }

  Future<void> stopRecording(double duration) async {
    final recordedFilePath = await _recorder.stop();
    if (recordedFilePath != null) {
      final uri = Uri.tryParse(recordedFilePath);
      if (uri != null) {
        final file = File.fromUri(uri);
        recordedFile = UnstoredAbiliaFile.newFile(file);
        print(recordedFile);
      }
      emit(StoppedSoundState(recordedFile));
    }
  }

  Future<void> deleteRecording() async {
    recordedFile = AbiliaFile.empty;
    emit(StoppedSoundState(AbiliaFile.empty));
  }

  Future<void> saveRecording() async {
    emit(SaveRecordingState(
        recordedFile, recordedFile.id != originalSoundFile.id));
  }
}
