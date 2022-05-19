part of 'package:seagull/bloc/settings/speech_support/voices_cubit.dart';

class VoiceData extends Equatable {
  final String name;
  final int type;
  final String lang;
  final List<VoiceFile> files;
  late final int size =
      (files.fold<int>(0, (pre, e) => pre + e.size) / 1000000).round();
  VoiceData(this.name, this.type, this.lang, this.files);
  factory VoiceData.fromJson(Map<String, dynamic> json) => VoiceData(
        json['name'],
        json['type'],
        json['lang'],
        json['files']
            .map<VoiceFile>(
              (e) => VoiceFile(
                e['downloadUrl'],
                int.parse(e['size']),
                e['md5'],
                e['localPath'],
              ),
            )
            .toList(),
      );

  @override
  List<Object?> get props => [name, type, lang, files, size];
}

class VoiceFile extends Equatable {
  final String downloadUrl;
  final int size;
  final String md5;
  final String localPath;

  const VoiceFile(this.downloadUrl, this.size, this.md5, this.localPath);

  @override
  List<Object?> get props => [downloadUrl, size, md5, localPath];
}
