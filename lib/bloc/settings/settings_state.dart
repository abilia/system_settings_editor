part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool textToSpeech;
  final bool speakEveryWord;
  final String voice;
  final double speechRate;

  const SettingsState({
    required this.textToSpeech,
    this.speakEveryWord = false,
    this.voice = '',
    this.speechRate = 0,
  });

  SettingsState copyWith({
    bool? textToSpeech,
    bool? speakEveryWord,
    String? voice,
    double? speechRate,
  }) =>
      SettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
        speakEveryWord: speakEveryWord ?? this.speakEveryWord,
        voice: voice ?? this.voice,
        speechRate: speechRate ?? this.speechRate,
      );

  @override
  List<Object> get props => [textToSpeech, speakEveryWord, voice, speechRate];
}
