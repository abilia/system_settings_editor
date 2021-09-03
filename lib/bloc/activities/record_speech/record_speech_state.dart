part of 'record_speech_cubit.dart';

enum RecordState {
  StoppedEmpty,
  Recording,
  StoppedNotEmpty,
  Playing,
  Recording2
}

class RecordSpeechState extends Equatable {
  final RecordState state;
  const RecordSpeechState(this.state);
  @override
  List<Object?> get props => [state];
}
