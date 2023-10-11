part of 'alarm_page_bloc.dart';

@immutable
sealed class AlarmPageState {
  final ActivityDay activityDay;
  const AlarmPageState(this.activityDay);
  bool get hasExtraSound =>
      activityDay.activity.textToSpeech &&
          activityDay.activity.description.isNotEmpty ||
      activityDay.activity.extras.startTimeExtraAlarm.isNotEmpty;
}

final class AlarmPageOpen extends AlarmPageState {
  const AlarmPageOpen(super.activityDay);
}

final class AlarmPlaying extends AlarmPageOpen {
  const AlarmPlaying(super.activity);
}

final class AlarmPageClosed extends AlarmPageState {
  const AlarmPageClosed(super.activityDay);
}
