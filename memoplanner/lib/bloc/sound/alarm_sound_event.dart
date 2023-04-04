part of 'alarm_sound_bloc.dart';

abstract class AlarmSoundEvent {
  const AlarmSoundEvent();
}

abstract class PlayAlarmSoundEvent extends AlarmSoundEvent {
  final Sound sound;
  const PlayAlarmSoundEvent(this.sound);
}

class PlayAlarmSound extends PlayAlarmSoundEvent {
  const PlayAlarmSound(super.sound);
}

class PlayAlarmSoundAsMedia extends PlayAlarmSoundEvent {
  const PlayAlarmSoundAsMedia(super.sound);
}

class StopAlarmSound extends AlarmSoundEvent {
  const StopAlarmSound();
}

class AlarmSoundCompleted extends AlarmSoundEvent {
  const AlarmSoundCompleted();
}
