import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as _path;
import 'package:mime/mime.dart' as _mime;
import 'package:path_provider/path_provider.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';

part 'sound_state.dart';

class SoundCubit extends Cubit<SoundState> {
  final log = Logger('AudioPlayer');
  static const tmpFileEnding = 'mp3';

  final FileStorage storage;
  final UserFileBloc userFileBloc;
  final AudioPlayer audioPlayer;
  final AudioCache audioCache;

  final Map<AbiliaFile, File> _fileMap = {};

  late final StreamSubscription audioPositionChanged;
  late final StreamSubscription onPlayerCompletion;
  late final StreamSubscription onPlayerError;

  SoundCubit({
    required this.storage,
    required this.userFileBloc,
  })  : audioPlayer = AudioPlayer(),
        audioCache = AudioCache(),
        super(NoSoundPlaying()) {
    audioCache.fixedPlayer = audioPlayer;
    onPlayerCompletion = audioPlayer.onPlayerCompletion.listen((_) {
      emit(const NoSoundPlaying());
    });
    onPlayerError = audioPlayer.onPlayerError.listen((event) {
      log.warning(event);
      emit(const NoSoundPlaying());
    });
    audioPositionChanged = audioPlayer.onAudioPositionChanged.listen(
      (position) async {
        final s = state;
        if (s is SoundPlaying) {
          final duration =
              s.duration == 0 ? await audioPlayer.getDuration() : s.duration;
          emit(
            SoundPlaying(
              s.currentSound,
              duration: duration,
              position: position,
            ),
          );
        }
      },
    );
  }

  Future<void> play(AbiliaFile abiliaFile) async {
    final file = _fileMap[abiliaFile] ?? await _resolveFile(abiliaFile);
    if (file != null) {
      await audioPlayer.play(file.path, isLocal: true);
      emit(SoundPlaying(abiliaFile));
    }
  }

  Future<File?> _resolveFile(AbiliaFile abiliaFile) async {
    if (abiliaFile is UnstoredAbiliaFile) {
      return _fileMap[abiliaFile] = abiliaFile.file;
    }
    final userFile = userFileBloc.state.getUserFileOrNull(abiliaFile);
    if (userFile != null) {
      final f = await _resoveFromUserFile(userFile);
      return f != null ? _fileMap[abiliaFile] = f : null;
    }
  }

  Future<File?> _resoveFromUserFile(UserFile userFile) async {
    final file = userFileBloc.state.getFileOrTempFile(userFile, storage);

    if (file == null || !await file.exists()) return null;

    if (!Platform.isIOS || _path.extension(file.path).isNotEmpty) return file;

    final contentType = userFile.contentType;
    final extension = contentType != null
        ? _mime.extensionFromMime(contentType)
        : tmpFileEnding;

    final tmpPath = _path.join(
      (await getTemporaryDirectory()).path,
      '${userFile.id}.$extension',
    );

    final tmpFile = File(tmpPath);

    if (await tmpFile.exists()) return tmpFile;

    return file.copy(tmpPath);
  }

  Future<void> stopSound() async {
    await audioPlayer.stop();
    emit(NoSoundPlaying());
  }

  @override
  Future<void> close() async {
    await super.close();
    await audioPlayer.dispose();
    await audioPositionChanged.cancel();
    await onPlayerCompletion.cancel();
    await onPlayerError.cancel();
  }
}
