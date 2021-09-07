part of 'record_sound_cubit.dart';

enum RecordState { Stopped, Recording, Playing }

class RecordSoundState extends Equatable {
  final RecordState state;
  final AbiliaFile recordedFile;
  const RecordSoundState(this.state, this.recordedFile);
  @override
  List<Object?> get props => [state, recordedFile];
}
