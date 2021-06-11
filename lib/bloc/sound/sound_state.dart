part of 'sound_cubit.dart';

class SoundState extends Equatable {
  final Sound? currentSound;

  SoundState({this.currentSound});

  @override
  List<Object?> get props => [currentSound];
}
