part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool textToSpeech;

  SettingsState({
    this.textToSpeech,
  });

  SettingsState copyWith({
    bool textToSpeech,
  }) {
    return SettingsState(
      textToSpeech: textToSpeech ?? this.textToSpeech,
    );
  }

  @override
  List<Object> get props => [
        textToSpeech,
      ];
}
