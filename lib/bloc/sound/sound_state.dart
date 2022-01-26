part of 'sound_cubit.dart';

abstract class SoundState extends Equatable {
  final Duration duration;
  const SoundState([this.duration = Duration.zero]);
}

class NoSoundPlaying extends SoundState {
  const NoSoundPlaying(Duration duration) : super(duration);
  @override
  List<Object?> get props => [];
}

class SoundPlaying extends SoundState {
  final AbiliaFile currentSound;
  final Duration position;
  double get progress => duration <= Duration.zero
      ? 0
      : min((position.inMilliseconds / duration.inMilliseconds), 1.0);

  const SoundPlaying(
    this.currentSound, {
    this.position = Duration.zero,
    required Duration duration,
  }) : super(duration);

  @override
  List<Object?> get props => [currentSound, duration, position];
}

class SoundDuration extends SoundState {
  const SoundDuration(Duration duration) : super(duration);

  @override
  List<Object?> get props => [duration];
}
