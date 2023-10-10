import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:user_files/bloc/user_file_bloc.dart';
import 'package:user_files/models/all.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'alarm_page_event.dart';

part 'alarm_page_state.dart';

class AlarmPageBloc extends Bloc<_AlarmPageEvent, AlarmPageState> {
  late final Timer alarmLoopTimer;
  late final Timer closeAlarmPageTimer;

  late final StreamSubscription audioPlayerSubscription;

  final _log = Logger((AlarmPageBloc).toString());

  final TtsHandler ttsHandler;
  final AudioPlayer audioPlayer;
  final FileStorage storage;
  final UserFileBloc userFileBloc;

  AlarmPageBloc({
    required this.audioPlayer,
    required this.storage,
    required this.userFileBloc,
    required ActivityDay activity,
    required this.ttsHandler,
  }) : super(AlarmPageOpen(activity)) {
    on<_CloseAlarmPage>((event, emit) => emit(AlarmPageClosed(state.activity)),
        transformer: droppable());
    on<_PlayAlarmSound>(_playAlarm, transformer: droppable());
    on<CancelAlarm>(_cancelAlarm, transformer: droppable());
    on<StopAlarm>(_stopAlarm, transformer: droppable());
    on<PlayAfter>(_playAfter, transformer: droppable());

    alarmLoopTimer = Timer.periodic(
      const Duration(minutes: 3),
      (t) => add(_PlayAlarmSound()),
    );
    closeAlarmPageTimer = Timer(
      const Duration(minutes: 30),
      () => add(_CloseAlarmPage()),
    );

    audioPlayerSubscription = audioPlayer.onPlayerComplete.listen(
      (event) => add(StopAlarm()),
    );
    unawaited(WakelockPlus.enable());
    add(_PlayAlarmSound());
  }

  void _cancelAlarm(
    CancelAlarm event,
    Emitter<AlarmPageState> emit,
  ) {
    if (alarmLoopTimer.isActive) {
      alarmLoopTimer.cancel();
      if (state is AlarmPlaying) {
        _log.info('CancelAlarm is Stopping alarm sound');
        add(StopAlarm());
      }
    }
  }

  Future<void> _stopAlarm(
    StopAlarm event,
    Emitter<AlarmPageState> emit,
  ) async {
    _log.info('Stopping alarm sound is Stopping alarm sound');
    await _stopSounds();
    emit(AlarmPageOpen(state.activity));
  }

  Future<void> _stopSounds() async {
    await FlutterRingtonePlayer.stop();
    await audioPlayer.stop();
    await ttsHandler.stop().timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => _log.warning('ttsHandler could not stop...'),
        );
  }

  Future<void> _playAlarm(
    _AlarmPageEvent event,
    Emitter<AlarmPageState> emit,
  ) async {
    emit(AlarmPlaying(state.activity));
    await FlutterRingtonePlayer.playNotification();
    // Can't await the notification sound to finish, will just add a delay here
    await Future.delayed(const Duration(seconds: 2));
    if (!alarmLoopTimer.isActive) return;
    await _playAfter(event, emit);
  }

  Future<void> _playAfter(
    _AlarmPageEvent event,
    Emitter<AlarmPageState> emit,
  ) async {
    emit(AlarmPlaying(state.activity));
    final playing = await _playSpeech() || await _playDescription(emit);
    if (!playing) emit(AlarmPageOpen(state.activity));
  }

  Future<bool> _playDescription(
    Emitter<AlarmPageState> emit,
  ) async {
    final playTts = state.activity.activity.textToSpeech;
    final description = '${state.activity.activity.title}. '
        '${state.activity.activity.description}';
    if (!playTts && description.isEmpty) return false;
    await ttsHandler.speak(description);
    emit(AlarmPageOpen(state.activity));
    return true;
  }

  Future<bool> _playSpeech() async {
    final startTimeExtraAlarm =
        state.activity.activity.extras.startTimeExtraAlarm;
    if (startTimeExtraAlarm.isEmpty) return false;
    final file = _resolveFile(startTimeExtraAlarm);
    if (file == null) return false;
    await audioPlayer.play(DeviceFileSource(file.path));
    return true;
  }

  File? _resolveFile(AbiliaFile abiliaFile) {
    final userFile = userFileBloc.state.getUserFileOrNull(abiliaFile);
    if (userFile == null) return null;
    return userFileBloc.state.getFileOrTempFile(userFile, storage);
  }

  @override
  Future<void> close() async {
    await _stopSounds();
    await WakelockPlus.disable();
    await audioPlayerSubscription.cancel();
    alarmLoopTimer.cancel();
    closeAlarmPageTimer.cancel();
    return super.close();
  }
}
