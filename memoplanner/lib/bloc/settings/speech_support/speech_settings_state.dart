part of 'speech_settings_cubit.dart';

class SpeechSettingsState extends Equatable {
  final bool textToSpeech;
  final bool _speakEveryWord;
  final String voice;
  final double speechRate;

  bool get speakEveryWord => textToSpeech && _speakEveryWord;

  SpeechSettingsState.fromDb(VoiceDb voiceDb)
      : textToSpeech = voiceDb.textToSpeech,
        _speakEveryWord = voiceDb.speakEveryWord,
        voice = voiceDb.voice,
        speechRate = voiceDb.speechRate;

  const SpeechSettingsState({
    required this.textToSpeech,
    bool speakEveryWord = false,
    this.voice = '',
    this.speechRate = 0,
  }) : _speakEveryWord = speakEveryWord;

  SpeechSettingsState copyWith({
    bool? textToSpeech,
    bool? speakEveryWord,
    String? voice,
    double? speechRate,
  }) =>
      SpeechSettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
        speakEveryWord: speakEveryWord ?? _speakEveryWord,
        voice: voice ?? this.voice,
        speechRate: speechRate ?? this.speechRate,
      );

  @override
  List<Object> get props => [textToSpeech, _speakEveryWord, voice, speechRate];
}
