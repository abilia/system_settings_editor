import 'package:mocktail/mocktail.dart';
import 'package:text_to_speech/voice_db.dart';

class FakeVoiceDb extends Fake implements VoiceDb {
  @override
  Future setVoice(String voice) async {}

  @override
  bool get textToSpeech => true;

  @override
  bool get speakEveryWord => false;

  @override
  String get voice => 'Erik';

  @override
  double get speechRate => 100;
}
