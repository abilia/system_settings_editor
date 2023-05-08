import 'package:http/http.dart';
import 'package:memoplanner/models/settings/speech_support/voice_data.dart';

class WrongRevisionException implements Exception {
  String errMsg() => 'Unavailable';
}

class VoiceFileDownloadException implements Exception {
  final VoiceFile voiceFile;
  final String? message;
  VoiceFileDownloadException(this.voiceFile, [this.message]);
  @override
  String toString() => 'failed to download voice file: $voiceFile, ($message)';
}

class StatusCodeException implements Exception {
  final Response response;
  final String? message;
  StatusCodeException(this.response, [this.message])
      : assert(response.statusCode != 200);
  @override
  String toString() => 'Wrong status code in response: '
      '${response.statusCode}, $response, $message';
}

class FetchSessionsException implements Exception {
  FetchSessionsException(this.statusCode);
  final int statusCode;
}

class SyncFailedException implements Exception {
  SyncFailedException([this.e]);
  final Exception? e;
  @override
  String toString() => 'Sync failed $e';
}
