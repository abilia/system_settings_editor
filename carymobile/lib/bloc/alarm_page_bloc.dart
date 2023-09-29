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
    on<_CloseAlarmPageEvent>(
        (event, emit) => emit(CloseAlarmPage(state.activity)));
    on<_PlayAlarmSoundEvent>(
        (event, emit) async => FlutterRingtonePlayer.playNotification());

    on<AlarmPageTouchedEvent>((event, emit) async {
      await FlutterRingtonePlayer.stop();
      alarmLoopTimer.cancel();
    });

    alarmLoopTimer = Timer.periodic(
      const Duration(minutes: 5),
      (t) => add(_PlayAlarmSoundEvent()),
    );
    closeAlarmPageTimer =
        Timer(const Duration(minutes: 30), () => add(_CloseAlarmPageEvent()));
    unawaited(WakelockPlus.enable());
    add(_PlayAlarmSoundEvent());
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    alarmLoopTimer.cancel();
    closeAlarmPageTimer.cancel();
    return super.close();
  }
}
