part of 'sound_cubit.dart';

abstract class SoundState extends Equatable {
  const SoundState();
}

class NoSoundPlaying extends SoundState {
  const NoSoundPlaying();
  @override
  List<Object?> get props => [];
}

class SoundPlaying extends SoundState {
  final Object currentSound;
  final int duration;
  final Duration position;
  double get progress => duration <= 0 ? 0 : position.inMilliseconds / duration;

  const SoundPlaying(
    this.currentSound, {
    this.duration = 0,
    this.position = Duration.zero,
  });

  @override
  List<Object?> get props => [currentSound, duration, position];
}
