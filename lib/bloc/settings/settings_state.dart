part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool textToSpeech;

  const SettingsState({required this.textToSpeech});

  SettingsState copyWith({bool? textToSpeech}) => SettingsState(
        textToSpeech: textToSpeech ?? this.textToSpeech,
      );

  @override
  List<Object> get props => [textToSpeech];
}
