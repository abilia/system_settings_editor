part of 'speech_settings_cubit.dart';

class SpeechSettingsState extends Equatable {
  final bool speakEveryWord;
  final String voice;
  final double speechRate;

  const SpeechSettingsState({
    this.speakEveryWord = false,
    this.voice = '',
    this.speechRate = 0,
  });

  SpeechSettingsState copyWith({
    bool? speakEveryWord,
    String? voice,
    double? speechRate,
  }) =>
      SpeechSettingsState(
        speakEveryWord: speakEveryWord ?? this.speakEveryWord,
        voice: voice ?? this.voice,
        speechRate: speechRate ?? this.speechRate,
      );

  @override
  List<Object> get props => [speakEveryWord, voice, speechRate];
}
