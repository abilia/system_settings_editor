part of 'record_sound_cubit.dart';

abstract class RecordSoundState extends Equatable {
  final AbiliaFile recordedFile;
  final Duration duration;

  const RecordSoundState(
    this.recordedFile,
    this.duration,
  );

  @override
  List<Object?> get props => [recordedFile, duration];
}

class EmptyRecordSoundState extends RecordSoundState {
  const EmptyRecordSoundState() : super(AbiliaFile.empty, Duration.zero);
}

abstract class RecordedSoundState extends RecordSoundState {
  const RecordedSoundState(super.recordedFile, super.duration);
}

class UnchangedRecordingSoundState extends RecordedSoundState {
  const UnchangedRecordingSoundState(super.recordedFile, super.duration);
}

class RecordingSoundState extends RecordSoundState {
  double get progress =>
      duration.inMilliseconds /
      RecordSoundCubit.maxRecordingTime.inMilliseconds;

  const RecordingSoundState(duration) : super(AbiliaFile.empty, duration);

  @override
  List<Object?> get props => [recordedFile, progress, duration];
}

class NewRecordedSoundState extends RecordedSoundState {
  final UnstoredAbiliaFile unstoredAbiliaFile;

  const NewRecordedSoundState(this.unstoredAbiliaFile, duration)
      : super(unstoredAbiliaFile, duration);
}
