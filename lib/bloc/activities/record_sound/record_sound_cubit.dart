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
  RecordSoundCubit({
    required this.onSoundRecorded,
    required recordedFile,
  }) : super(
          RecordSoundState(RecordState.Stopped, recordedFile),
        );

  final _recorder = Record();
  final void Function(AbiliaFile value) onSoundRecorded;

  Future<void> startRecording() async {
    var result = await _recorder.hasPermission();
    if (result) {
      var tempDir = await getApplicationDocumentsDirectory();
      var tempPath = '${tempDir.path}';
      await _recorder.start(path: '$tempPath/' + Uuid().v4());
      emit(RecordSoundState(RecordState.Recording, AbiliaFile.empty));
    }
  }

  Future<void> stopRecording(double duration) async {
    final recordedFilePath = await _recorder.stop();
    var recordedFile;
    if (recordedFilePath != null) {
      final uri = Uri.tryParse(recordedFilePath);
      if (uri != null) {
        final file = File.fromUri(uri);
        recordedFile = UnstoredAbiliaFile.newFile(file);
        onSoundRecorded(
          recordedFile,
        );
      }
      emit(RecordSoundState(RecordState.Stopped, recordedFile));
    }
  }

  Future<void> deleteRecording() async {
    onSoundRecorded(
      AbiliaFile.empty,
    );
    emit(RecordSoundState(RecordState.Stopped, AbiliaFile.empty));
  }
}
