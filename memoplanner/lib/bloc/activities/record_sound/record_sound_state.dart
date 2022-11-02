part of 'record_sound_cubit.dart';

abstract class RecordSoundState extends Equatable {
  final Duration duration;

  const RecordSoundState(this.duration);

  @override
  List<Object?> get props => [duration];
}

class EmptyRecordSoundState extends RecordSoundState {
  const EmptyRecordSoundState() : super(Duration.zero);
}

abstract class RecordedSoundState extends RecordSoundState {
  final AbiliaFile recordedFile;
  const RecordedSoundState(this.recordedFile, duration) : super(duration);

  @override
  List<Object?> get props => [recordedFile, duration];
}

class UnchangedRecordingSoundState extends RecordedSoundState {
  const UnchangedRecordingSoundState(AbiliaFile recordedFile, Duration duration)
      : super(recordedFile, duration);
}

class RecordingSoundState extends RecordSoundState {
  double get progress =>
      duration.inMilliseconds /
      RecordSoundCubit.maxRecordingTime.inMilliseconds;
  const RecordingSoundState(duration) : super(duration);
  @override
  List<Object?> get props => [progress, duration];
}

class NewRecordedSoundState extends RecordedSoundState {
  final UnstoredAbiliaFile unstoredAbiliaFile;
  const NewRecordedSoundState(this.unstoredAbiliaFile, duration)
      : super(unstoredAbiliaFile, duration);
}
