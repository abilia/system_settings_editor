part of 'record_sound_cubit.dart';

// enum RecordState { Stopped, Recording, Playing }

abstract class RecordSoundState extends Equatable {
  // final RecordState state;
  final AbiliaFile recordedFile;
  const RecordSoundState(this.recordedFile);
  @override
  List<Object?> get props => [recordedFile];
}

class RecordingSoundState extends RecordSoundState {
  RecordingSoundState(AbiliaFile recordedFile) : super(recordedFile);
}

class PlayingSoundState extends RecordSoundState {
  PlayingSoundState(AbiliaFile recordedFile) : super(recordedFile);
}

class StoppedSoundState extends RecordSoundState {
  StoppedSoundState(AbiliaFile recordedFile) : super(recordedFile);
}

class SaveRecordingState extends RecordSoundState {
  final bool newRecording;

  SaveRecordingState(AbiliaFile recordedFile, this.newRecording)
      : super(recordedFile);
}
