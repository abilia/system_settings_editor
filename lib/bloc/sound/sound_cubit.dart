import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final log = Logger((SoundCubit).toString());
  static const tmpFileEnding = 'mp3';

  final FileStorage storage;
  final UserFileCubit userFileCubit;
  final AudioPlayer audioPlayer = AudioPlayer();

  final Map<AbiliaFile, File> _fileMap = {};

  late final StreamSubscription audioPositionChanged;
  late final StreamSubscription onPlayerCompletion;

  SoundCubit({
    required this.storage,
    required this.userFileCubit,
  }) : super(const NoSoundPlaying()) {
    onPlayerCompletion = audioPlayer.onPlayerComplete.listen((_) {
      emit(const NoSoundPlaying());
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
            emit(
              SoundPlaying(
                s.currentSound,
                duration: duration ?? s.duration,
                position: position,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> play(AbiliaFile abiliaFile) async {
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
    emit(const NoSoundPlaying());
  }

  @override
  Future<void> close() async {
    await super.close();
    await audioPlayer.dispose();
    await audioPositionChanged.cancel();
    await onPlayerCompletion.cancel();
  }
}
