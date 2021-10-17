part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool textToSpeech;

  const SettingsState({required this.textToSpeech});

  SettingsState copyWith({bool? textToSpeech, bool? alarmsDisabled}) =>
      SettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
      );

  @override
  List<Object> get props => [textToSpeech];
}
