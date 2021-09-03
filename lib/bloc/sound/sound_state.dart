part of 'sound_cubit.dart';

class SoundState extends Equatable {
  final Object? currentSound;

  SoundState({this.currentSound});

  @override
  List<Object?> get props => [currentSound];
}
