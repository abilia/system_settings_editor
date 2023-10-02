part of 'alarm_page_bloc.dart';

@immutable
sealed class _AlarmPageEvent {}

final class _PlayAlarmSound extends _AlarmPageEvent {}

final class StopAlarmSound extends _AlarmPageEvent {}

final class _CloseAlarmPage extends _AlarmPageEvent {}
