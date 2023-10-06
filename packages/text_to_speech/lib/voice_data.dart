import 'package:equatable/equatable.dart';

class VoiceData extends Equatable {
  final String name, lang, countryCode;
  final VoiceFile file;

  const VoiceData({
    required this.name,
    required this.lang,
    required this.countryCode,
    required this.file,
  });

  factory VoiceData.fromJson(json) => VoiceData(
        name: json['name'],
        lang: json['lang'],
        countryCode: json['countryCode'],
        file: VoiceFile.fromJson(json['file']),
      );

  @override
  String toString() =>
      '{ name: $name, lang: $lang, countryCode: $countryCode (${file.size}MB) }';

  @override
  List<Object?> get props => [name, lang, countryCode, file];
}

class VoiceFile extends Equatable {
  final String md5;
  final Uri downloadUrl;
  final int size;

  int get sizeInMB => (size / 1000000).round();

  VoiceFile({
    required String downloadUrl,
    required this.md5,
    required this.size,
  }) : downloadUrl = Uri.parse(downloadUrl);

  factory VoiceFile.fromJson(Map<String, dynamic> json) => VoiceFile(
        downloadUrl: json['downloadUrl'],
        md5: json['md5'],
        size: json['size'],
      );

  @override
  String toString() => '{ md5: $md5, downloadUrl: $downloadUrl, size: $size }';

  @override
  List<Object?> get props => [md5];
}
