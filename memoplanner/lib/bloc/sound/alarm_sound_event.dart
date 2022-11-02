part of 'alarm_sound_bloc.dart';

abstract class AlarmSoundEvent {
  const AlarmSoundEvent();
}

class PlaySoundAlarm extends AlarmSoundEvent {
  final Sound sound;
  const PlaySoundAlarm(this.sound);
}

class StopSoundAlarm extends AlarmSoundEvent {
  const StopSoundAlarm();
}

class RestartSoundAlarm extends AlarmSoundEvent {
  final Sound sound;
  const RestartSoundAlarm(this.sound);
}

class SoundAlarmCompleted extends AlarmSoundEvent {
  const SoundAlarmCompleted();
}
