import 'package:mocktail/mocktail.dart';
import 'package:text_to_speech/text_to_speech.dart';

class FakeAcapelaTtsHandler extends Fake implements AcapelaTtsHandler {
  @override
  Future<dynamic> speak(String text) async {}

  @override
  Future<dynamic> stop() async {}

  @override
  Future<dynamic> pause() async {}

  @override
  Future<bool> setVoice(Map<String, String> voice) async => true;

  @override
  Future<bool> setSpeechRate(double speed) async => true;

  @override
  Future<List<Object?>> get availableVoices => Future.value(List.empty());
}
