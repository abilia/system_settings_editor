part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class DotsInTimepillarUpdated extends SettingsEvent {
  final bool dotsInTimepillar;

  DotsInTimepillarUpdated(this.dotsInTimepillar);
  @override
  String toString() =>
      'DotsInTimepillarUpdated {dotsInTimepillar: $dotsInTimepillar}';
}

class TextToSpeechUpdated extends SettingsEvent {
  final bool textToSpeech;

  TextToSpeechUpdated(this.textToSpeech);

  @override
  String toString() => 'TextToSpeechUpdated {textToSpeech: $textToSpeech}';
}

class AlarmsDisabledUpdated extends SettingsEvent {
  final bool alarmsDisabled;

  AlarmsDisabledUpdated(this.alarmsDisabled);

  @override
  String toString() =>
      'AlarmsDisabledUpdated {alarmsDisabled: $alarmsDisabled}';
}
