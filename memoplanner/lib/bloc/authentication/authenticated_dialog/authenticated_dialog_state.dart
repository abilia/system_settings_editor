part of 'authenticated_dialog_cubit.dart';

class AuthenticatedDialogState extends Equatable {
  final bool termsOfUse,
      termsOfUseLoaded,
      starterSet,
      starterSetLoaded,
      fullscreenAlarm,
      fullscreenAlarmLoaded;

  bool get dialogsReady =>
      termsOfUseLoaded && starterSetLoaded && fullscreenAlarmLoaded;

  bool get anyDialog => termsOfUse || starterSet || fullscreenAlarm;

  bool get showDialog => dialogsReady && anyDialog;

  const AuthenticatedDialogState({
    this.termsOfUse = false,
    this.termsOfUseLoaded = false,
    this.starterSet = false,
    this.starterSetLoaded = false,
    this.fullscreenAlarm = false,
    this.fullscreenAlarmLoaded = false,
  });

  AuthenticatedDialogState copyWith({
    bool? termsOfUse,
    bool? starterSet,
    bool? fullscreenAlarm,
  }) =>
      AuthenticatedDialogState(
        termsOfUse: termsOfUse ?? this.termsOfUse,
        termsOfUseLoaded: termsOfUseLoaded || termsOfUse != null,
        starterSet: starterSet ?? this.starterSet,
        starterSetLoaded: starterSetLoaded || starterSet != null,
        fullscreenAlarm: fullscreenAlarm ?? this.fullscreenAlarm,
        fullscreenAlarmLoaded: fullscreenAlarmLoaded || fullscreenAlarm != null,
      );

  @override
  List<Object?> get props => [
        termsOfUse,
        termsOfUseLoaded,
        starterSet,
        starterSetLoaded,
        fullscreenAlarm,
        fullscreenAlarmLoaded,
      ];
}
