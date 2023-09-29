part of 'alarm_page_bloc.dart';

@immutable
sealed class AlarmPageState {
  final ActivityDay activity;
  const AlarmPageState(this.activity);
}

final class AlarmPageOpen extends AlarmPageState {
  const AlarmPageOpen(super.activity);
}

final class CloseAlarmPage extends AlarmPageState {
  const CloseAlarmPage(super.activity);
}
