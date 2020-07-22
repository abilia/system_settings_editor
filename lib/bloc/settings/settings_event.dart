part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class DotsInTimepillarUpdated extends SettingsEvent {
  final bool dotsInTimepillar;

  DotsInTimepillarUpdated(this.dotsInTimepillar);
  @override
  String toString() =>
      'DotsInTimepillarUpdated {dotsInTimepillar: $dotsInTimepillar}';
}
