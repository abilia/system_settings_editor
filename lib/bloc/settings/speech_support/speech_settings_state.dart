part of 'speech_settings_cubit.dart';

class SpeechSettingsState extends Equatable {
  final bool textToSpeech;
  final bool speakEveryWord;
  final String voice;
  final double speechRate;

  const SpeechSettingsState({
    required this.textToSpeech,
    this.speakEveryWord = false,
    this.voice = '',
    this.speechRate = 0,
  });

  SpeechSettingsState copyWith({
    bool? textToSpeech,
    bool? speakEveryWord,
    String? voice,
    double? speechRate,
  }) =>
      SpeechSettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
        speakEveryWord: speakEveryWord ?? this.speakEveryWord,
        voice: voice ?? this.voice,
        speechRate: speechRate ?? this.speechRate,
      );

  @override
  List<Object> get props => [textToSpeech, speakEveryWord, voice, speechRate];
}
