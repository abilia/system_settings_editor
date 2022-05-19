part of '../../../bloc/settings/speech_support/voices_cubit.dart';

class VoiceData extends Equatable {
  final String name;
  final int type;
  final String lang;
  final List<VoiceFile> files;
  final int size;
  static const int _bytesPerMegaByte = 1000000;

  const VoiceData(this.name, this.type, this.lang, this.files, this.size);

  factory VoiceData.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    int type = json['type'];
    String lang = json['lang'];
    List<VoiceFile> files = json['files']
        .map<VoiceFile>((e) => VoiceFile(
            e['downloadUrl'], int.parse(e['size']), e['md5'], e['localPath']))
        .toList();
    int size = 0;
    for (var element in files) {
      size += element.size;
    }
    return VoiceData(name, type, lang, files, size ~/ _bytesPerMegaByte);
  }

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
