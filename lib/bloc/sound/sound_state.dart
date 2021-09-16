part of 'sound_cubit.dart';

class SoundState extends Equatable {
  final Sound? currentSound;

  const SoundState({this.currentSound});

  @override
  List<Object?> get props => [currentSound];
}
