part of 'alarm_page_bloc.dart';

@immutable
sealed class _AlarmPageEvent {}

final class _PlayAlarmSoundEvent extends _AlarmPageEvent {}

final class AlarmPageTouchedEvent extends _AlarmPageEvent {}

final class _CloseAlarmPageEvent extends _AlarmPageEvent {}
