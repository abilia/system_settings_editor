import 'package:text_to_speech/voice_data.dart';

class VoiceFileDownloadException implements Exception {
  final VoiceFile voiceFile;
  final String? message;
  VoiceFileDownloadException(this.voiceFile, [this.message]);
  @override
  String toString() => 'failed to download voice file: $voiceFile, ($message)';
}
