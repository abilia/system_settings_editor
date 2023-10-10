part of 'alarm_page_bloc.dart';

@immutable
sealed class AlarmPageState {
  final ActivityDay activity;
  const AlarmPageState(this.activity);
  bool get hasExtraSound =>
      activity.activity.textToSpeech &&
          activity.activity.description.isNotEmpty ||
      activity.activity.extras.startTimeExtraAlarm.isNotEmpty;
}

final class AlarmPageOpen extends AlarmPageState {
  const AlarmPageOpen(super.activity);
}

final class AlarmPlaying extends AlarmPageOpen {
  const AlarmPlaying(super.activity);
}

final class AlarmPageClosed extends AlarmPageState {
  const AlarmPageClosed(super.activity);
}
