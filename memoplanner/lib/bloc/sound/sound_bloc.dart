import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart' as mime;
import 'package:path_provider/path_provider.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

part 'sound_event.dart';
part 'sound_state.dart';

class SoundBloc extends Bloc<SoundEvent, SoundState> {
  static const tmpFileEnding = 'mp3';
  static final spamProtectionDelay = 250.milliseconds();

  final log = Logger((SoundBloc).toString());

  final FileStorage storage;
  final UserFileCubit userFileCubit;

  final Map<AbiliaFile, File> _fileMap = {};

  late AudioPlayer audioPlayer;
  late StreamSubscription audioPositionChanged;
  late StreamSubscription onPlayerCompletion;

  SoundBloc({
    required this.storage,
    required this.userFileCubit,
  }) : super(const NoSoundPlaying()) {
    on<SoundControlEvent>(_onEvent,
        transformer: _throttle(spamProtectionDelay));
    on<SoundCallbackEvent>(_onEvent, transformer: _throttle(Duration.zero));
    add(const ResetPlayer());
  }

  Future _onEvent(
    SoundEvent event,
    Emitter<SoundState> emit,
  ) async {
    if (event is PlaySound) {
      await _playSound(event.abiliaFile, emit);
    } else if (event is StopSound) {
      await _stopSound(emit);
    } else if (event is ResetPlayer) {
      await _resetAudioPlayer();
    } else if (event is SoundCompleted) {
      emit(const NoSoundPlaying());
    } else if (event is PositionChanged) {
      emit(
        SoundPlaying(
          event.currentSound,
          duration: event.duration,
          position: event.position,
        ),
      );
    }
  }

  Future<void> _playSound(
    AbiliaFile abiliaFile,
    Emitter<SoundState> emit,
  ) async {
    log.fine('trying to play: $abiliaFile');
    final file = await resolveFile(abiliaFile);
    if (file != null) {
      log.fine('playing: $file');
      await audioPlayer.play(DeviceFileSource(file.path));
      emit(SoundPlaying(abiliaFile));
    } else {
      log.warning('could not resolve $abiliaFile from user files');
    }
  }

  Future<File?> resolveFile(AbiliaFile abiliaFile) async =>
      _fileMap[abiliaFile] ?? await _resolveFile(abiliaFile);

  Future<File?> _resolveFile(AbiliaFile abiliaFile) async {
    if (abiliaFile is UnstoredAbiliaFile) {
      return _fileMap[abiliaFile] = abiliaFile.file;
    }
    if (userFileCubit.state is! UserFilesLoaded) {
      log.fine('waiting for user files loaded');
      await userFileCubit.stream
          .firstWhere((state) => state is UserFilesLoaded);
    }
    final userFile = userFileCubit.state.getUserFileOrNull(abiliaFile);
    if (userFile != null) {
      final f = await _resoveFromUserFile(userFile);
      return f != null ? _fileMap[abiliaFile] = f : null;
    }
    return null;
  }

  Future<File?> _resoveFromUserFile(UserFile userFile) async {
    final file = userFileCubit.state.getFileOrTempFile(userFile, storage);

    if (file == null || !await file.exists()) return null;

    if (!Platform.isIOS || path.extension(file.path).isNotEmpty) return file;

    final contentType = userFile.contentType;
    final extension = contentType != null
        ? mime.extensionFromMime(contentType)
        : tmpFileEnding;

    final tmpPath = path.join(
      (await getTemporaryDirectory()).path,
      '${userFile.id}.$extension',
    );

    final tmpFile = File(tmpPath);

    if (await tmpFile.exists()) return tmpFile;

    return file.copy(tmpPath);
  }

  Future<void> _stopSound(Emitter<SoundState> emit) async {
    await audioPlayer.stop();
    emit(const NoSoundPlaying());
  }

  /// 220818 - audioPlayer v1.0.1
  /// Creating a new AudioPlayer is necessary because the current plugin tries
  /// to set the previous source before setting the newly supplied source and
  /// since we have deleted it, it won't work.
  /// No official issue has been raised at this point, but there are some
  /// possible fixes:
  /// 1. Allow null as source. Then we could pass null before our new sound
  /// 2. Null source in WrappedPlayer when calling release() (Easiest?)
  /// 3. Don't try to set old source before new one in WrappedPlayer. (Maybe
  /// other implications).
  Future<void> _resetAudioPlayer() async {
    audioPlayer = AudioPlayer();
    onPlayerCompletion = audioPlayer.onPlayerComplete.listen((_) {
      add(const SoundCompleted());
    });
    audioPositionChanged = audioPlayer.onPositionChanged
        .throttleTime(const Duration(milliseconds: 25))
        .listen(
      (position) async {
        final s = state;
        if (s is SoundPlaying) {
          final duration = s.duration == 0
              ? (await audioPlayer.getDuration())?.inMilliseconds
              : s.duration;
          if (!isClosed) {
            add(
              PositionChanged(
                s.currentSound,
                duration ?? s.duration,
                position,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await super.close();
    await audioPlayer.dispose();
    await audioPositionChanged.cancel();
    await onPlayerCompletion.cancel();
  }
}

EventTransformer<Event> _throttle<Event>(Duration delay) =>
    (events, mapper) => events.throttleTime(delay).asyncExpand(mapper);
