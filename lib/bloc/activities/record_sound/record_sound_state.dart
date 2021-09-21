part of 'record_sound_cubit.dart';

abstract class RecordSoundState extends Equatable {
  const RecordSoundState();
}

class EmptyRecordSoundState extends RecordSoundState {
  const EmptyRecordSoundState();

  @override
  List<Object?> get props => [];
}

abstract class RecordedSoundState extends RecordSoundState {
  final AbiliaFile recordedFile;
  const RecordedSoundState(this.recordedFile);
  @override
  List<Object?> get props => [recordedFile];
}

class UnchangedRecordingSoundState extends RecordedSoundState {
  const UnchangedRecordingSoundState(AbiliaFile recordedFile)
      : super(recordedFile);
}

class RecordingSoundState extends EmptyRecordSoundState {
  final Duration duration;
  double get progress =>
      duration.inMilliseconds /
      RecordSoundCubit.maxRecordingTime.inMilliseconds;
  const RecordingSoundState(this.duration) : super();
  @override
  List<Object?> get props => [progress];
}

class NewRecordedSoundState extends RecordedSoundState {
  final UnstoredAbiliaFile unstoredAbiliaFile;
  const NewRecordedSoundState(this.unstoredAbiliaFile)
      : super(unstoredAbiliaFile);
}
