part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool dotsInTimepillar;

  SettingsState(this.dotsInTimepillar);

  @override
  List<Object> get props => [dotsInTimepillar];
}
