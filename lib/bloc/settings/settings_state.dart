part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool textToSpeech;
  final bool alarmsDisabled;

  const SettingsState(
      {required this.textToSpeech, required this.alarmsDisabled});

  SettingsState copyWith({bool? textToSpeech, bool? alarmsDisabled}) =>
      SettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
        alarmsDisabled: alarmsDisabled ?? this.alarmsDisabled,
      );

  @override
  List<Object> get props => [textToSpeech, alarmsDisabled];
}
