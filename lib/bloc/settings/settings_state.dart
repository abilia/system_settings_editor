part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool textToSpeech;

  SettingsState({required this.textToSpeech});

  SettingsState copyWith({bool? textToSpeech}) => SettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
      );

  @override
  List<Object> get props => [textToSpeech];
}
