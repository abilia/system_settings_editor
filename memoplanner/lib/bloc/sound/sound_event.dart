part of 'sound_bloc.dart';

abstract class SoundEvent {
  const SoundEvent();
}

abstract class SoundControlEvent extends SoundEvent {
  const SoundControlEvent();
}

abstract class SoundCallbackEvent extends SoundEvent {
  const SoundCallbackEvent();
}

class PlaySound extends SoundControlEvent {
  final AbiliaFile abiliaFile;
  const PlaySound(this.abiliaFile);
}

class StopSound extends SoundControlEvent {
  const StopSound();
}

class ResetPlayer extends SoundControlEvent {
  const ResetPlayer();
}

class SoundCompleted extends SoundCallbackEvent {
  const SoundCompleted();
}

class PositionChanged extends SoundCallbackEvent {
  final AbiliaFile currentSound;
  final int duration;
  final Duration position;

  const PositionChanged(
    this.currentSound,
    this.duration,
    this.position,
  );
}
