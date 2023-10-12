part of 'alarm_page_bloc.dart';

@immutable
sealed class _AlarmPageEvent {}

final class _PlayAlarm extends _AlarmPageEvent {}

final class StopAlarm extends _AlarmPageEvent {}

final class CancelAlarm extends _AlarmPageEvent {}

final class PlayAfter extends _AlarmPageEvent {}

final class _CloseAlarm extends _AlarmPageEvent {}
