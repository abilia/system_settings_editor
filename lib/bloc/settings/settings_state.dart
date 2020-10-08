part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool dotsInTimepillar, textToSpeech;

  SettingsState({
    this.dotsInTimepillar,
    this.textToSpeech,
  });

  SettingsState copyWith({
    bool dotsInTimepillar,
    bool textToSpeech,
  }) {
    return SettingsState(
      dotsInTimepillar: dotsInTimepillar ?? this.dotsInTimepillar,
      textToSpeech: textToSpeech ?? this.textToSpeech,
    );
  }

  @override
  List<Object> get props => [
        dotsInTimepillar,
        textToSpeech,
      ];
}
