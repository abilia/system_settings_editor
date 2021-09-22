part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  const PermissionState(this.status);

  factory PermissionState.empty() => PermissionState(UnmodifiableMapView({}));

  final UnmodifiableMapView<Permission, PermissionStatus> status;

  @visibleForTesting
  PermissionState update(Map<Permission, PermissionStatus> newStates) {
    var map = <Permission, PermissionStatus>{};
    for (final newState in newStates.entries) {
      if (newState.value != PermissionStatus.denied ||
          Map.of(status)[newState.key] != PermissionStatus.permanentlyDenied) {
        map.putIfAbsent(newState.key, () => newState.value);
      }
    }
    return PermissionState(
      UnmodifiableMapView(
        Map.of(status)
          ..addAll(
            map,
          ),
      ),
    );
  }

  bool get notificationDenied =>
      status[Permission.notification]?.isDeniedOrPermenantlyDenied ?? false;

  bool get fullscreenNotGranted =>
      !Platform.isIOS &&
      !(status[Permission.systemAlertWindow]?.isGranted ?? false);

  bool get importantPermissionMissing =>
      notificationDenied || fullscreenNotGranted;

  @override
  List<Object> get props => [status];

  @override
  bool get stringify => true;
}
