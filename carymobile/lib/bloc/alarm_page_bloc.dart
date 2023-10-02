import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:meta/meta.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'alarm_page_event.dart';

part 'alarm_page_state.dart';

class AlarmPageBloc extends Bloc<_AlarmPageEvent, AlarmPageState> {
  late final Timer alarmLoopTimer;
  late final Timer closeAlarmPageTimer;

  AlarmPageBloc(ActivityDay activity) : super(AlarmPageOpen(activity)) {
    on<_CloseAlarmPage>((event, emit) => emit(AlarmPageClosed(state.activity)));
    on<_PlayAlarmSound>(
        (event, emit) async => FlutterRingtonePlayer.playNotification());

    on<StopAlarmSound>((event, emit) async {
      await FlutterRingtonePlayer.stop();
      alarmLoopTimer.cancel();
    });

    alarmLoopTimer = Timer.periodic(
      const Duration(minutes: 5),
      (t) => add(_PlayAlarmSound()),
    );
    closeAlarmPageTimer =
        Timer(const Duration(minutes: 30), () => add(_CloseAlarmPage()));
    unawaited(WakelockPlus.enable());
    add(_PlayAlarmSound());
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    alarmLoopTimer.cancel();
    closeAlarmPageTimer.cancel();
    return super.close();
  }
}
