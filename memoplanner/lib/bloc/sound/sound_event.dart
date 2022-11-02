part of 'sound_bloc.dart';

abstract class SoundEvent {
  const SoundEvent();
}

class PlaySound extends SoundEvent {
  final AbiliaFile abiliaFile;
  const PlaySound(this.abiliaFile);
}

class StopSound extends SoundEvent {
  const StopSound();
}

class ResetPlayer extends SoundEvent {
  const ResetPlayer();
}

class SoundCompleted extends SoundEvent {
  const SoundCompleted();
}

class PositionChanged extends SoundEvent {
  final AbiliaFile currentSound;
  final int duration;
  final Duration position;

  const PositionChanged(
    this.currentSound,
    this.duration,
    this.position,
  );
}
